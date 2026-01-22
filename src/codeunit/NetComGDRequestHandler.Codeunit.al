// codeunit 50105 "NetCom GD Request Handler"
// {
//     Description = 'Handles Google Drive API calls.';

//     procedure CreateRequestParamsAuthCode(): Text
//     var
//         NetComGDSetup: Record "NetCom GD Setup";
//         NetComGDTokens: Codeunit "Netcom GD Tokens";
//     begin
//         NetComGDSetup.Get();
//         exit(StrSubstNo(CreateUrlParamsTemplate(5),
//                     NetComGDTokens.CodeTok(), NetComGDSetup.AuthCode,
//                     NetComGDTokens.ClientID(), NetComGDSetup.ClientID,
//                     NetComGDTokens.ClientSecret(), NetComGDSetup.ClientSecret,
//                     NetComGDTokens.RedirectUri(), NetComGDSetup.RedirectURI,
//                     NetComGDTokens.GrantType(), NetComGDTokens.AuthorizationCode()));
//     end;

//     procedure CreateRequestParamsRefreshToken(): Text
//     var
//         NetComGDSetup: Record "NetCom GD Setup";
//         NetComGDTokens: Codeunit "NetCom GD Tokens";
//     begin
//         NetComGDSetup.Get();
//         exit(StrSubstNo(CreateUrlParamsTemplate(4),
//                     NetComGDTokens.ClientID(), NetComGDSetup.ClientID,
//                     NetComGDTokens.ClientSecret(), NetComGDSetup.ClientSecret,
//                     NetComGDTokens.RefreshToken(), NetComGDSetup.RefreshToken,
//                     NetComGDTokens.GrantType(), NetComGDTokens.RefreshToken()));
//     end;

//     procedure CreateRequestParamsRedirect(): Text
//     var
//         NetComGDSetup: Record "NetCom GD Setup";
//         NetComGDTokens: Codeunit "NetCom GD Tokens";
//     begin
//         NetComGDSetup.Get();
//         exit(StrSubstNo(CreateUrlParamsTemplate(4),
//                         NetComGDTokens.ClientID(), NetComGDSetup.ClientID,
//                         NetComGDTokens.RedirectUri(), NetComGDSetup.RedirectURI,
//                         NetComGDTokens.ResponseType(), NetComGDTokens.CodeTok(),
//                         NetComGDTokens.Scope(), NetComGDSetup.AuthScope));
//     end;

//     procedure DeleteFile(FileID: Text): Text
//     var
//         NetComGDSetup: Record "NetCom GD Setup";
//         NetComGDJsonHelper: Codeunit "NetCom GD Json Helper";
//         NetComGDTokens: Codeunit "NetCom GD Tokens";
//         MyHttpClient: HttpClient;
//         MyHttpRequestMessage: HttpRequestMessage;
//         MyHttpResponseMessage: HttpResponseMessage;
//         Url: Text;
//         ResponseText: Text;
//     begin
//         NetComGDSetup.Get();
//         Url := StrSubstNo(UrlWithIdAndParamsTok, NetComGDSetup.APIScope, FileID, StrSubstNo(CreateUrlParamsTemplate(1),
//                     NetComGDTokens.KeyTok(), NetComGDSetup.ClientID));
//         MyHttpRequestMessage.SetRequestUri(Url);
//         MyHttpRequestMessage.Method := 'DELETE';
//         MyHttpClient.DefaultRequestHeaders.Add(
//             NetComGDTokens.Authorization(), StrSubstNo(AuthHdrValueTok, NetComGDSetup.TokenType, NetComGDSetup.AccessToken));
//         if MyHttpClient.Send(MyHttpRequestMessage, MyHttpResponseMessage) then begin
//             MyHttpResponseMessage.Content.ReadAs(ResponseText);
//             exit(ResponseText);
//         end;
//         exit(NetComGDJsonHelper.CreateSimpleJson(NetComGDTokens.ErrorTok(), MyHttpResponseMessage.HttpStatusCode));
//     end;

//     procedure GetErrorText(): Text
//     begin
//         // INFO: This function is used for Get only, in future it may be removed
//         exit(CurrentErrorText);
//     end;

//     procedure GetMedia(var MediaInStream: InStream; FileID: Text)
//     var
//         NetComGDSetup: Record "NetCom GD Setup";
//         NetComGDJsonHelper: Codeunit "NetCom GD Json Helper";
//         NetComGDErrorHandler: Codeunit "NetCom GD Error Handler";
//         NetComGDTokens: Codeunit "NetCom GD Tokens";
//         MyHttpClient: HttpClient;
//         MyHttpResponseMessage: HttpResponseMessage;
//         Url: Text;
//         ErrorText: Text;
//     begin
//         if FileID = '' then
//             NetComGDErrorHandler.ThrowFileIDMissingErr();

//         Clear(ErrorText);
//         NetComGDSetup.Get();
//         Url := StrSubstNo(UrlWithIdAndParamsTok, NetComGDSetup.APIScope, FileID, StrSubstNo(CreateUrlParamsTemplate(2),
//                     NetComGDTokens.KeyTok(), NetComGDSetup.ClientID,
//                     NetComGDTokens.AltTok(), NetComGDTokens.MediaTok()));
//         MyHttpClient.DefaultRequestHeaders.Add(
//             NetComGDTokens.Authorization(), StrSubstNo(AuthHdrValueTok, NetComGDSetup.TokenType, NetComGDSetup.AccessToken));
//         if MyHttpClient.Get(Url, MyHttpResponseMessage) then
//             if MyHttpResponseMessage.IsSuccessStatusCode then
//                 MyHttpResponseMessage.Content.ReadAs(MediaInStream)
//             else begin
//                 MyHttpResponseMessage.Content.ReadAs(ErrorText);
//                 SetErrorText(NetComGDJsonHelper.CreateSimpleJson(NetComGDTokens.ErrorTok(), ErrorText));
//             end
//         else
//             SetErrorText(NetComGDJsonHelper.CreateSimpleJson(NetComGDTokens.ErrorTok(), MyHttpResponseMessage.HttpStatusCode));
//     end;

//     procedure PatchFile(MediaInStream: InStream; FileID: Text): Text
//     var
//         NetComGDSetup: Record "NetCom GD Setup";
//         NetComGDJsonHelper: Codeunit "NetCom GD Json Helper";
//         NetComGDTokens: Codeunit "NetCom GD Tokens";
//         MyHttpContent: HttpContent;
//         ContentHeaders: HttpHeaders;
//         MyHttpRequestMessage: HttpRequestMessage;
//         MyHttpClient: HttpClient;
//         MyHttpResponseMessage: HttpResponseMessage;
//         Url: Text;
//         ResponseText: Text;
//     begin
//         NetComGDSetup.Get();
//         MyHttpContent.WriteFrom(MediaInStream);
//         MyHttpContent.GetHeaders(ContentHeaders);
//         ContentHeaders.Clear();
//         ContentHeaders.Add(NetComGDTokens.ContentType(), NetComGDTokens.MimeTypeJpeg());
//         MyHttpRequestMessage.Content := MyHttpContent;
//         Url := StrSubstNo(UrlWithIdAndParamsTok, NetComGDSetup.APIUploadScope, FileID, StrSubstNo(CreateUrlParamsTemplate(2),
//                     NetComGDTokens.KeyTok(), NetComGDSetup.ClientID,
//                     NetComGDTokens.UploadType(), NetComGDTokens.MediaTok()));
//         MyHttpRequestMessage.SetRequestUri(Url);
//         MyHttpRequestMessage.Method := 'PATCH';
//         MyHttpClient.DefaultRequestHeaders.Add(
//             NetComGDTokens.Authorization(), StrSubstNo(AuthHdrValueTok, NetComGDSetup.TokenType, NetComGDSetup.AccessToken));
//         if MyHttpClient.Send(MyHttpRequestMessage, MyHttpResponseMessage) then begin
//             MyHttpResponseMessage.Content.ReadAs(ResponseText);
//             exit(ResponseText);
//         end;
//         exit(NetComGDJsonHelper.CreateSimpleJson(NetComGDTokens.ErrorTok(), MyHttpResponseMessage.HttpStatusCode));
//     end;

//     procedure PatchMetadata(NewMetadata: Text; FileID: Text): Text
//     var
//         NetComGDSetup: Record "NetCom GD Setup";
//         NetComGDJsonHelper: Codeunit "NetCom GD Json Helper";
//         NetComGDTokens: Codeunit "NetCom GD Tokens";
//         MyHttpContent: HttpContent;
//         ContentHeaders: HttpHeaders;
//         MyHttpRequestMessage: HttpRequestMessage;
//         MyHttpClient: HttpClient;
//         MyHttpResponseMessage: HttpResponseMessage;
//         Url: Text;
//         ResponseText: Text;
//     begin
//         //STEP5 (Upload)
//         NetComGDSetup.Get();
//         MyHttpContent.WriteFrom(NewMetadata);
//         MyHttpContent.GetHeaders(ContentHeaders);
//         ContentHeaders.Clear();
//         ContentHeaders.Add(NetComGDTokens.ContentType(), NetComGDTokens.MimeTypeJson());
//         MyHttpRequestMessage.Content := MyHttpContent;
//         Url := StrSubstNo(UrlWithIdAndParamsTok, NetComGDSetup.APIScope, FileID, StrSubstNo(CreateUrlParamsTemplate(1),
//                     NetComGDTokens.KeyTok(), NetComGDSetup.ClientID));
//         MyHttpRequestMessage.SetRequestUri(Url);
//         MyHttpRequestMessage.Method := 'PATCH';
//         MyHttpClient.DefaultRequestHeaders.Add(
//             NetComGDTokens.Authorization(), StrSubstNo(AuthHdrValueTok, NetComGDSetup.TokenType, NetComGDSetup.AccessToken));
//         if MyHttpClient.Send(MyHttpRequestMessage, MyHttpResponseMessage) then begin
//             MyHttpResponseMessage.Content.ReadAs(ResponseText);
//             exit(ResponseText);
//         end;
//         exit(NetComGDJsonHelper.CreateSimpleJson(NetComGDTokens.ErrorTok(), MyHttpResponseMessage.HttpStatusCode));
//     end;

//     procedure PostFile(var MediaInStream: InStream): Text;
//     var
//         NetComGDSetup: Record "NetCom GD Setup";
//         NetComGDJsonHelper: Codeunit "NetCom GD Json Helper";
//         NetComGDTokens: Codeunit "NetCom GD Tokens";
//         MyHttpContent: HttpContent;
//         ContentHeaders: HttpHeaders;
//         MyHttpClient: HttpClient;
//         MyHttpResponseMessage: HttpResponseMessage;
//         Url: Text;
//         ResponseText: Text;
//     begin
//         //STEP1 (Upload)
//         NetComGDSetup.Get();
//         MyHttpContent.WriteFrom(MediaInStream);
//         MyHttpContent.GetHeaders(ContentHeaders);
//         ContentHeaders.Clear();

//         //ContentHeaders.Add(NetComGDTokens.ContentType(), NetComGDTokens.MimeTypeJpeg());
//         ContentHeaders.Add(NetComGDTokens.ContentType(), NetComGDTokens.MimeTypeCSV());
//         Url := StrSubstNo(UrlWithParamsTok, NetComGDSetup.APIUploadScope, StrSubstNo(CreateUrlParamsTemplate(2),
//                     NetComGDTokens.KeyTok(), NetComGDSetup.ClientID,
//         NetComGDTokens.UploadType(), NetComGDTokens.MediaTok()));

//         MyHttpClient.DefaultRequestHeaders.Add(
//             NetComGDTokens.Authorization(), StrSubstNo(AuthHdrValueTok, NetComGDSetup.TokenType, NetComGDSetup.AccessToken));
//         if MyHttpClient.Post(Url, MyHttpContent, MyHttpResponseMessage) then begin
//             MyHttpResponseMessage.Content().ReadAs(ResponseText);
//             exit(ResponseText);
//         end;
//         exit(NetComGDJsonHelper.CreateSimpleJson(NetComGDTokens.ErrorTok(), MyHttpResponseMessage.HttpStatusCode));
//     end;

//     procedure RequestAccessToken(RequestBody: Text): Text
//     var
//         NetComGDSetup: Record "NetCom GD Setup";
//         NetComGDJsonHelper: Codeunit "NetCom GD Json Helper";
//         NetComGDTokens: Codeunit "NetCom GD Tokens";
//         MyHttpContent: HttpContent;
//         ContentHeaders: HttpHeaders;
//         MyHttpClient: HttpClient;
//         MyHttpResponseMessage: HttpResponseMessage;
//         ResponseText: Text;
//     begin
//         NetComGDSetup.Get();
//         MyHttpContent.WriteFrom(RequestBody);
//         MyHttpContent.GetHeaders(ContentHeaders);
//         ContentHeaders.Clear();
//         ContentHeaders.Add(NetComGDTokens.ContentType(), NetComGDTokens.MimeTypeFormUrlEncoded());
//         if MyHttpClient.Post(NetComGDSetup.TokenURI, MyHttpContent, MyHttpResponseMessage) then begin
//             MyHttpResponseMessage.Content().ReadAs(ResponseText);
//             exit(ResponseText);
//         end;
//         exit(NetComGDJsonHelper.CreateSimpleJson(NetComGDTokens.ErrorTok(), MyHttpResponseMessage.HttpStatusCode));
//     end;

//     local procedure CreateUrlParamsTemplate(QtyParams: Integer): Text
//     var
//         // GDIErrorHandler: Codeunit "GDI Error Handler";
//         TemplText: Text;
//         Index: Integer;
//     begin
//         // Creates texts like '%1=%2&%3=%4'
//         if QtyParams < 1 then
//             Error(BadParameterErr, 'CreateUrlParamsTemplate', QtyParams);
//         // GDIErrorHandler.ThrowBadParameterErr('CreateUrlParamsTemplate', QtyParams);

//         for Index := 1 to QtyParams do
//             TemplText += '%' + Format(2 * Index - 1) + '=%' + Format(2 * Index) + '&';
//         exit(TemplText.Remove(StrLen(TemplText)));
//     end;

//     local procedure SetErrorText(NewErrorText: Text)
//     begin
//         CurrentErrorText := NewErrorText;
//     end;

//     // procedure Deprecated_GetMetadata(FileID: Text): Text
//     // var
//     //     NetComGDSetup: Record "NetCom GD Setup";
//     //     // GDIErrorHandler: Codeunit "GDI Error Handler";
//     //     NetComGDTokens: Codeunit "NetCom GD Tokens";
//     //     MyHttpClient: HttpClient;
//     //     MyHttpResponseMessage: HttpResponseMessage;
//     //     Url: Text;
//     //     ResponseText: Text;
//     // begin
//     //     // INFO: this function is not used at the moment
//     //     // when it's added it should be aligned with Get
//     //     if FileID = '' then
//     //         // GDIErrorHandler.ThrowFileIDMissingErr();
//     //         Error(Err001Lbl);

//     //     NetComGDSetup.Get();
//     //     Url := StrSubstNo(UrlWithIdAndParamsTok, NetComGDSetup.APIScope, FileID, StrSubstNo(CreateUrlParamsTemplate(1),
//     //                 NetComGDTokens.KeyTok(), NetComGDSetup.ClientID));
//     //     MyHttpClient.DefaultRequestHeaders.Add(
//     //         NetComGDTokens.Authorization(), StrSubstNo(AuthHdrValueTok, NetComGDSetup.TokenType, NetComGDSetup.AccessToken));
//     //     MyHttpClient.Get(Url, MyHttpResponseMessage);
//     //     MyHttpResponseMessage.Content.ReadAs(ResponseText);
//     //     exit(ResponseText);
//     // end;

//     var
//         AuthHdrValueTok: Label '%1 %2', Comment = '%1 = token type; %2 = token value'; // bad name
//         UrlWithParamsTok: Label '%1?%2', Comment = '%1 = Url; %2 = parameters';
//         UrlWithIdAndParamsTok: Label '%1/%2?%3', Comment = '%1 = Url; %2 = entity id; %3 = parameters';
//         CurrentErrorText: Text;
//         // Err001Lbl: Label 'File ID Missing!';
//         BadParameterErr: Label '%1 says: bad parameter value %2.', Comment = '%1 = function, %2 = parameter value';
// }