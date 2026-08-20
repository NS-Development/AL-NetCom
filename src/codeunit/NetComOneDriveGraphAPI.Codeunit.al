codeunit 50104 "NetCom One Drive Graph API"
{
    trigger OnRun()
    var
        NetComCustomerPriceService: Record "NetCom Customer Price Service";
        NetComCustomerPriceService2: Record "NetCom Customer Price Service";
        NetComInloadService: Record "NetCom Inload Service";
        NetComInloadService2: Record "NetCom Inload Service";
        JobQueueEntry: Record "Job Queue Entry";
        NetComOneDriveGraphAPI: Codeunit "NetCom One Drive Graph API";
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter("Object ID to Run", '%1|%2', 50103, 50107); //NetCom Customer Price Service
        JobQueueEntry.SetRange("Status", JobQueueEntry."Status"::"In Process");
        if JobQueueEntry.IsEmpty then begin
            NetComCustomerPriceService.Reset();
            NetComCustomerPriceService.SetRange(Export, true);
            if NetComCustomerPriceService.FindSet() then
                repeat
                    NetComCustomerPriceService2 := NetComCustomerPriceService;
                    NetComCustomerPriceService2.SetRecFilter();
                    NetComOneDriveGraphAPI.UploadFile(NetComCustomerPriceService2);
                until NetComCustomerPriceService.Next() = 0;

            NetComInloadService.Reset();
            NetComInloadService.SetRange(Export, true);
            if NetComInloadService.FindSet() then
                repeat
                    NetComInloadService2 := NetComInloadService;
                    NetComInloadService2.SetRecFilter();
                    NetComOneDriveGraphAPI.UploadFileInload(NetComInloadService2);
                until NetComInloadService.Next() = 0;
        end;
    end;

    procedure UploadFile(var NetComCustomerPriceService: Record "NetCom Customer Price Service")
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        Filename: Text;
    begin
        TempBlob.CreateOutStream(OutStream);

        if NetComCustomerPriceService."Document Reference ID".ExportStream(OutStream) then begin
            Filename := 'Business Central/' + CompanyName + '/PriceList_' + NetComCustomerPriceService."Customer No." + '.' + 'csv';
            if PutFile(Filename, TempBlob.CreateInStream()) then begin
                NetComCustomerPriceService.Validate(NetComCustomerPriceService."Latest Export", CurrentDateTime);
                NetComCustomerPriceService.Validate(Export, false);
                NetComCustomerPriceService.Modify(true);
            end;
        end;
    end;

    procedure UploadFileInload(var NetComInloadService: Record "NetCom Inload Service")
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        Filename: Text;
    begin
        TempBlob.CreateOutStream(OutStream);

        if NetComInloadService."Document Reference ID".ExportStream(OutStream) then begin
            Filename := 'Business Central/' + CompanyName + '/Inload_' + NetComInloadService."Customer No." + '.' + 'csv';
            if PutFile(Filename, TempBlob.CreateInStream()) then begin
                NetComInloadService.Validate(NetComInloadService."Latest Export", CurrentDateTime);
                NetComInloadService.Validate(Export, false);
                NetComInloadService.Modify(true);
            end;
        end;
    end;

    internal procedure PutFile(SourceName: Text; RequestInstream: InStream): Boolean;
    var
        TypeHelper: Codeunit "Type Helper";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        RequestHttpHeaders: HttpHeaders;
        RequestURL: Text;
    begin
        Initialize();
        NetComOneDriveSetup.TestField("Authentication User");

        SourceName := TypeHelper.UrlEncode(SourceName);

        RequestURL := 'https://graph.microsoft.com/v1.0/users/' + NetComOneDriveSetup."Authentication User" + '/drive/root:/' + SourceName + ':/content';
        SetupHttpRequestMessage(HttpRequestMessage, 'PUT', RequestURL);
        HttpRequestMessage.GetHeaders(RequestHttpHeaders);

        SetupHttpContent(HttpRequestMessage, RequestInStream);

        if CallRESTWebservice(HttpRequestMessage, HttpResponseMessage) then
            exit(true);
    end;

    local procedure CallRESTWebservice(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        HttpClient: HttpClient;
        Builder: TextBuilder;
        Textl001Lbl: Label 'The call to the webservice failed!\%1', Comment = '%1 = Error';
        Textl002Lbl: Label 'The webservice returned an error message: Status Code: %1. Message: %2.', Comment = '%1 = HttpResponseMessage.HttpStatusCode, %2 = HttpResponseMessage.ReasonPhrase';
    begin

        ClearLastError();
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(Textl001Lbl, GetLastErrorText());

        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            Builder.Clear();
            Builder.Append(StrSubstNo(Textl002Lbl, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase));

            Error(Builder.ToText());
        end;

        exit(true);
    end;

    local procedure GetToken(): Text
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
        ResponseString: Text;
        Url: Text;
        Builder: TextBuilder;
        JObject: JsonObject;
        "Label001_Lbl": Label 'The call to the webservice failed!';
        "Label002_Lbl": Label 'The webservice returned an error message: Status Code: %1. Message: %2.', Comment = '%1 = HttpResponseMessage.HttpStatusCode, %2 = HttpResponseMessage.ReasonPhrase';
    begin
        Url := 'https://login.microsoftonline.com/' + NetComOneDriveSetup."Azure Tenant ID" + '/oauth2/v2.0/token';

        Builder.Clear();
        Builder.Append('grant_type=client_credentials');
        Builder.Append('&client_id=' + NetComOneDriveSetup."Azure App Client ID");
        Builder.Append('&client_secret=' + NetComOneDriveSetup."Azure App Client Secret");
        Builder.Append('&scope=' + 'https://graph.microsoft.com/.default');

        HttpContent.Clear();
        HttpContent.WriteFrom(Builder.ToText());
        HttpContent.GetHeaders(ContentHeaders);

        ContentHeaders.Clear();
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        HttpRequestMessage.SetRequestUri(Url);
        HttpRequestMessage.Method('POST');
        HttpRequestMessage.Content(HttpContent);

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error("Label001_Lbl");

        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            Builder.Clear();
            Builder.Append(StrSubstNo("Label002_Lbl", HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase));

            Error(Builder.ToText());
        end;

        HttpResponseMessage.Content.ReadAs(ResponseString);

        if ResponseString <> '' then begin
            JObject.ReadFrom(ResponseString);

            exit(GetJsonTokenText(JObject, 'access_token'));
        end else
            Error("Label001_Lbl")
    end;

    local procedure SetupHttpRequestMessage(var HttpRequestMessage: HttpRequestMessage; RESTMethod: Code[10]; RequestURL: Text)
    var
        RequestHttpHeaders: HttpHeaders;
    begin
        HttpRequestMessage.SetRequestUri(RequestURL);
        HttpRequestMessage.Method(RESTMethod);

        HttpRequestMessage.GetHeaders(RequestHttpHeaders);
        AddDefaultRequestHttpHeaders(RequestHttpHeaders);
    end;

    local procedure SetupHttpContent(var HttpRequestMessage: HttpRequestMessage; RequestInstream: InStream)
    var
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
    begin
        HttpContent.WriteFrom(RequestInstream);
        HttpContent.GetHeaders(contentHeaders);
        AddDefaultContentHttpHeaders(contentHeaders);

        HttpRequestMessage.Content(HttpContent);
    end;

    local procedure AddDefaultRequestHttpHeaders(var RequestHttpHeaders: HttpHeaders)
    begin
        RequestHttpHeaders.Clear();
        RequestHttpHeaders.Add('Authorization', 'Bearer ' + GetToken());
    end;

    local procedure AddDefaultContentHttpHeaders(var ContentHeaders: HttpHeaders)
    begin
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');
    end;

    [TryFunction]
    local procedure Initialize()
    begin
        if not Initialized then begin
            NetComOneDriveSetup.Get();
            Initialized := true;
        end;
    end;

    local procedure GetJsonTokenText(JObject: JsonObject; Member: Text): Text
    var
        Result: JsonToken;
    begin
        if JObject.Get(Member, Result) then
            if Format(Result) <> 'null' then
                exit(Result.AsValue().AsText());
    end;

    var
        NetComOneDriveSetup: Record "NetCom OneDrive Setup";
        Initialized: Boolean;
}