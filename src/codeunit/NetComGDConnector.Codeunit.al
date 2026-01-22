// codeunit 50104 "NetCom GD Connector"
// {
//     procedure Authorize()
//     var
//         NetComGDMethod: enum "NetCom GD Method";
//     begin
//         // Use this function for calls from setup UI
//         //STEP1 (Authorize)
//         Authorize(NetComGDMethod::Authorize);
//     end;

//     procedure Authorize(NetComGDMethod: enum "NetCom GD Method")
//     var
//         NetComGDSetup: Record "NetCom GD Setup";
//         NetComGDRequestHandler: Codeunit "NetCom GD Request Handler";
//         NetComGDJsonHelper: Codeunit "NetCom GD Json Helper";
//         NetComGDErrorHandler: Codeunit "NetCom GD Error Handler";
//         NetComGDTokens: Codeunit "NetCom GD Tokens";
//         // GDIProblem: Enum "GDI Problem";
//         ResponseJson: JsonObject;
//         RequestParams: Text;
//         ResponseText: Text;
//         // ErrorValue: Text;
//         RequestSentAtUTC: DateTime;
//     begin
//         //STEP2 (Authorize)
//         //STEP3 (Upload)
//         NetComGDSetup.Get();
//         if NetComGDSetup.AccessTokenIsAlive() then
//             exit;

//         NetComGDSetup.TestMandatoryAuthFields();
//         // if NetComGDSetup.Active then
//         //     RequestParams := NetComGDRequestHandler.CreateRequestParamsRefreshToken()
//         // else begin
//         if NetComGDSetup.AuthCode = '' then begin
//             RequestParams := NetComGDRequestHandler.CreateRequestParamsRedirect();
//             System.Hyperlink(StrSubstNo(UrlWithParamsTok, NetComGDSetup.AuthURI, RequestParams));
//             exit;
//         end;
//         RequestParams := NetComGDRequestHandler.CreateRequestParamsAuthCode();
//         // end;

//         RequestSentAtUTC := System.CurrentDateTime();
//         ResponseText := NetComGDRequestHandler.RequestAccessToken(RequestParams);

//         if NetComGDErrorHandler.ResponseHasError(NetComGDMethod, ResponseText) then begin
//             Message(ResponseText);
//             //NetComGDErrorHandler.GetError(NetComGDMethod, GDIProblem, ErrorValue);
//             // SetError(GDIProblem, NetComGDMethod, ErrorValue);
//             exit;
//         end;

//         ResponseJson.ReadFrom(ResponseText);
//         Clear(NetComGDSetup.AuthCode);
//         NetComGDSetup.Validate(AccessToken, NetComGDJsonHelper.GetTextValueFromJson(ResponseJson, NetComGDTokens.AccessToken()));
//         NetComGDSetup.Validate(TokenType, NetComGDJsonHelper.GetTextValueFromJson(ResponseJson, NetComGDTokens.TokenType()));
//         NetComGDSetup.Validate(IssuedUtc, RequestSentAtUTC);
//         NetComGDSetup.Validate(ExpiresIn, NetComGDJsonHelper.GetTextValueFromJson(ResponseJson, NetComGDTokens.ExpiresIn()));
//         // NetComGDSetup.Validate(LifeTime, CalcLifetime(NetComGDSetup.ExpiresIn, NetComGDSetup.LifeTime));
//         if not NetComGDSetup.Active then begin
//             // GDISetup.Validate(RefreshToken, GDIJsonHelper.GetTextValueFromJson(ResponseJson, GDITokens.RefreshToken()));
//             NetComGDSetup.Validate(Active, true);
//         end;
//         NetComGDSetup.Modify(true);
//     end;

//     //procedure GetError(var GDIMethod: enum "GDI Method"; var GDIProblem: enum "GDI Problem"; var ErrorValue: Text)
//     procedure GetError(var NetComGDMethod: enum "NetCom GD Method"; var ErrorValue: Text)
//     begin
//         NetComGDMethod := CurrentMethod;
//         // GDIProblem := CurrentProblem;
//         ErrorValue := CurrentErrorValue;
//     end;

//     // local procedure SetError(GDIProblem: enum "GDI Problem"; GDIMethod: Enum "GDI Method"; ErrorValue: Text)
//     // begin
//     //     ClearError();
//     //     CurrentProblem := GDIProblem;
//     //     CurrentMethod := GDIMethod;
//     //     CurrentErrorValue := ErrorValue;
//     // end;

//     // local procedure ClearError()
//     // begin
//     //     CurrentProblem := CurrentProblem::Undefined;
//     //     CurrentMethod := CurrentMethod::Undefined;
//     //     Clear(CurrentErrorValue);
//     // end;

//     var
//         UrlWithParamsTok: Label '%1?%2', Comment = '%1 = Url; %2 = parameters'; // duplicate, move
//         // CurrentProblem: enum "GDI Problem";
//         CurrentMethod: enum "NetCom GD Method";
//         CurrentErrorValue: text;
// }