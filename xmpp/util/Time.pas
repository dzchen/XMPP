unit Time;

interface
uses
  DateUtils,SysUtils,StrUtils;

  function JabberToDateTime(dt:string):TDateTime;overload;
  function DateTimeToJabber(dt:TDateTime):string;overload;
  function ISO_8601Date(dt:string):TDateTime;overload;
  function ISO_8601Date(dt:TDateTime):string;overload;
implementation
function JabberToDateTime(dt:string):TDateTime;
var
    rdate: TDateTime;
    ys, ms, ds, ts: Widestring;
    yw, mw, dw: Word;
    tt:TTimeZone;
begin
    // Converts assumed UTC time to local.
    // translate date from 20000110T19:54:00 to proper format..
    ys := Copy(dt, 1, 4);
    ms := Copy(dt, 5, 2);
    ds := Copy(dt, 7, 2);
    ts := Copy(dt, 10, 8);

    try
        yw := StrToInt(ys);
        mw := StrToInt(ms);
        dw := StrToInt(ds);

        if (TryEncodeDate(yw, mw, dw, rdate)) then begin
            rdate := rdate + StrToTime(ts);
            //Result := rdate - TimeZoneBias(); // Convert to local time
            tt:=TTimeZone.Create;
            Result:=tt.ToLocalTime(rdate);
        end
        else
            Result := Now();
    except
        Result := Now;
    end;
end;
function DateTimeToJabber(dt:TDateTime):string;
begin
  Result := FormatDateTime('yyyymmdd', dt);
    Result := Result + 'T';
    Result := Result + FormatDateTime('hh:nn:ss', dt);
end;
function ISO_8601Date(dt:string):TDateTime;
var
    rdate: TDateTime;
    ys, ms, ds, ts: Widestring;
    yw, mw, dw: Word;
    tzd: Widestring;
    tzd_hs: Widestring;
    tzd_ms: Widestring;
    tzd_hw: word;
    tzd_mw: word;
    tt:TTimeZone;
begin
    // Converts UTC or TZD time to Local Time
    // translate date from 2008-06-11T10:10:23.102Z (2008-06-11T10:10:23.102-06:00) or to properformat
    Result := Now();

    dt := Trim(dt);
    if (Length(dt) = 0) then exit;

    ys := Copy(dt, 1, 4);
    ms := Copy(dt, 6, 2);
    ds := Copy(dt, 9, 2);
    ts := Copy(dt, 12, 8);

    if (RightStr(dt, 1) = 'Z') then
    begin
        // Is UTC
        try
            yw := StrToInt(ys);
            mw := StrToInt(ms);
            dw := StrToInt(ds);

            if (TryEncodeDate(yw, mw, dw, rdate)) then begin
                rdate := rdate + StrToTime(ts);
                //Result := rdate - TimeZoneBias(); // Convert to local time
                 tt:=TTimeZone.Create;
            Result:=tt.ToLocalTime(rdate);
            end
            else
                Result := Now();
        except
            Result := Now;
        end;
    end
    else begin
        // Is not UTC so convert to UTC
        tzd := Copy(dt, Length(dt) - 5, 6);
        tzd_hs := Copy(tzd, 2, 2);
        tzd_ms := Copy(tzd, 5, 2);

        try
            yw := StrToInt(ys);
            mw := StrToInt(ms);
            dw := StrToInt(ds);
            tzd_hw := StrToInt(tzd_hs);
            tzd_mw := StrToInt(tzd_ms);

            if (TryEncodeDate(yw, mw, dw, rdate)) then
            begin
                rdate := rdate + StrToTime(ts);
                // modify time for TZD offset.
                if (LeftStr(tzd, 1) = '+') then
                begin
                    // Time is greater then UTC so subtract time
                    rdate := IncHour(rdate, (-1 * tzd_hw));
                    rdate := IncMinute(rdate, (-1 * tzd_mw));
                end
                else begin
                    // Time is less then UTC so add time
                    rdate := IncHour(rdate, tzd_hw);
                    rdate := IncMinute(rdate, tzd_mw);
                end;

                // Now that we have UTC, change ot local
                //Result := rdate - TimeZoneBias();
                 tt:=TTimeZone.Create;
            Result:=tt.ToLocalTime(rdate);
            end
            else begin
                Result := Now();
            end;
        except
            Result := Now();
        end;
    end;

end;
function ISO_8601Date(dt:TDateTime):string;
begin
  Result := FormatDateTime('yyyy-mm-dd', dt);
end;
end.
