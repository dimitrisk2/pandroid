{**********************************************************
Copyright (C) 2012-2016
Zeljko Cvijanovic www.zeljus.com (cvzeljko@gmail.com) &
Miran Horjak usbdoo@gmail.com
***********************************************************}
unit JNIUtils;

{$mode objfpc}{$H+}

interface

uses jni, Types;

//Opste
function JNI_JStringToString(env: PJNIEnv; JStr: JString): string;
function JNI_StringToJString(env: PJNIEnv; Str: string): jstring;

function JNI_JStringToWideString(Env: PJNIEnv; JStr: JString): WideString;
function JNI_WideStringToJString(Env: PJNIEnv; const WStr: WideString): JString;

function JNI_JStringArrayToStrings(Env: PJNIEnv; jStrings: jarray): TStringDynArray;  { Convert jarray to AnsiString array }
function JNI_StringsToJStringArray(Env: PJNIEnv; strings: TStringDynArray): jarray;   { Convert AnsiString array to jarray }

function JNI_JIntArrayToIntegers(Env: PJNIEnv; jarr: jintArray): TIntegerDynArray;    { Convert JIntArray to integer array }
function JNI_IntegersToJIntArray(Env: PJNIEnv; arr: TIntegerDynArray): JIntArray;     { Convert integer array to JIntArray }

function JNI_BytesToJByteArray(Env: PJNIEnv; Bytes: TByteDynArray): JByteArray;       { Convert byte array to JByteArray }
function JNI_JByteArrayToBytes(Env: PJNIEnv; JBytes: jbyteArray): TByteDynArray;      { Convert JByteArray to byte array }

implementation

//Opste
function JNI_JStringToString(env: PJNIEnv; JStr: JString): string;
var
  pAnsiCharTMP: pAnsiChar;
  pIsCopy: Byte;
begin
   // IsCopy := JNI_TRUE;

    if (JStr = nil) then begin
      Result := '';
      Exit;
    end;

     pAnsiCharTMP := env^^.GetStringUTFChars(env, JStr, @pIsCopy);

    if (pAnsiCharTMP = nil) then begin
      Result := '';
    end else begin
      Result := StrPas(pAnsiCharTMP); //Return the result;
       //Release the temp string
      Env^^.ReleaseStringUTFChars(env, JStr, pAnsiCharTMP);
    end;
end;

function JNI_StringToJString(env: PJNIEnv; Str: string): jstring;
begin
    Result := env^^.NewStringUTF(env, @Str[1]);
end;

////

function JNI_JStringToWideString(Env: PJNIEnv; JStr: JString): WideString;
var
  IsCopy: Pjboolean;
  Chars: PChar;
begin
  if JStr = nil then begin
    Result := '';
    Exit;
  end;

  Chars:= Env^^.GetStringUTFChars(Env, JStr, IsCopy);
  if Chars = nil then
     Result := ''
  else begin
      Result := WideString(Chars);
      Env^^.ReleaseStringUTFChars(Env, JStr, Chars);
    end;
end;

function JNI_WideStringToJString(Env: PJNIEnv; const WStr: WideString): JString;
begin
  Result := Env^^.NewString(Env, Pointer(WStr), Length(WStr));
end;


////

function JNI_JStringArrayToStrings(Env: PJNIEnv; jStrings: jarray): TStringDynArray;   //array of AnsiString;
var
  len, i: jsize;
  w_ret: TStringDynArray;
  obj: jobject;
begin
  len := Env^^.GetArrayLength(env, jStrings);
  SetLength(w_ret, len);
  for i := 0 to len - 1 do
  begin
    obj := env^^.GetObjectArrayElement(env, jStrings, i);
    w_ret[i] := JNI_JStringToString(Env, jString(obj));
  end;
  Result := w_ret;
end;

function JNI_StringsToJStringArray(Env: PJNIEnv; strings: TStringDynArray): jarray;
var
  i, len: cardinal;
  w_ret: jarray;
begin
  len := length(strings);
  w_ret := Env^^.NewObjectArray(Env, Len,Env^^.FindClass(Env,'java/lang/String'),JNI_StringToJString(Env,''));
  for i := 0 to len - 1 do
  begin
    Env^^.SetObjectArrayElement(Env, w_ret, i, JNI_StringToJString(env, strings[i]));
  end;
  Result := w_ret;
end;

///
function JNI_JIntArrayToIntegers(Env: PJNIEnv; jarr: jintArray): TIntegerDynArray;  // array of Integer
var
  w_ret: TIntegerDynArray;
  len: jint;
begin
  len := Env^^.GetArrayLength(Env, jarr);
  SetLength(w_ret, len);
  Env^^.GetIntArrayRegion(Env, jarr, 0, len, @w_ret[0]);
  Result := w_ret;
end;

function JNI_IntegersToJIntArray(Env: PJNIEnv; arr: TIntegerDynArray): JIntArray;
var
  len: cardinal;
  intArray: JIntArray;
begin
  if (arr = nil) then
  begin
    Result := nil;
    Exit;
  end;

  len := High(arr) + 1;
  intArray := Env^^.NewIntArray(Env, Len);
  Env^^.SetIntArrayRegion(Env, intArray, 0, len, @arr[0]);
  Result := intArray;
end;

//
{ Convert byte array to JByteArray }
function JNI_BytesToJByteArray(Env: PJNIEnv; Bytes: TByteDynArray): JByteArray;
var
  len: cardinal;
  byteArray: JByteArray;
begin
  if (bytes = nil) then
  begin
    Result := nil;
    Exit;
  end;

  len := High(Bytes) + 1;
  byteArray := Env^^.NewByteArray(Env, Len);
  Env^^.SetByteArrayRegion(Env, byteArray, 0, len, @Bytes[0]);
  Result := byteArray;
end;

function JNI_JByteArrayToBytes(Env: PJNIEnv; JBytes: jbyteArray): TByteDynArray;    //  array of Byte
var
  len: jsize;
  w_ret: TByteDynArray;
begin
  len := Env^^.GetArrayLength(env, JBytes);
  SetLength(w_ret,len);
  Env^^.GetByteArrayRegion(env, JBytes, 0, len, @w_ret[0]);
  Result := w_ret;
end;



end.

