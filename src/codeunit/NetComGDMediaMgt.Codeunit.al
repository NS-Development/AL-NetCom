// codeunit 50109 "NetCom GD Media Mgt."
// {
//     Description = 'Manages Google Drive API calls and handles Google Drive Media.';

//     procedure NetCom_CreateOnGoogleDrive(NetComCustomerPriceService: Record "NetCom Customer Price Service"; var MediaInStream: InStream; FileName: Text; MediaID: Integer)
//     var
//         // GDISetupMgt: Codeunit "GDI Setup Mgt.";
//         NetComGDConnector: Codeunit "NetCom GD Connector";
//         NetComGDRequestHandler: Codeunit "NetCom GD Request Handler";
//         NetComGDErrorHandler: Codeunit "NetCom GD Error Handler";
//         // GDIQueueHandler: Codeunit "GDI Queue Handler";
//         NetComGDJsonHelper: Codeunit "NetCom GD Json Helper";
//         NetComGDTokens: Codeunit "NetCom GD Tokens";
//         ResponseJson: JsonObject;
//         NetComGDMethod: Enum "NetCom GD Method";
//         // GDIProblem: Enum "GDI Problem";
//         // GDIStatus: Enum "GDI Status";
//         ResponseText: Text;
//         ErrorValue: Text;
//         FileID: Text;

//         QueueID: Integer;
//     begin
//         //STEP3 (Upload)
//         if FileName = '' then
//             NetComGDErrorHandler.ThrowFileNameMissingErr();

//         // if MediaID = 0 then
//         //     GDIErrorHandler.ThrowMediaIDMissingErr();

//         // QueueID := GDIQueueHandler.Create(GDIMethod::PostFile, GDIProblem::Undefined, MediaID, '');
//         // Commit();

//         NetComGDConnector.Authorize(NetComGDMethod::PostFile);
//         // GDISetupMgt.GetError(GDIMethod, GDIProblem, ErrorValue);
//         // if ErrorValue <> '' then begin
//         //     GDIQueueHandler.Update(QueueID, GDIStatus::"To Handle", GDIMethod, GDIProblem, MediaID, '', ErrorValue);
//         //     Commit();
//         //     exit;
//         // end;

//         ResponseText := NetComGDRequestHandler.PostFile(MediaInStream);
//         //Ved fejl...
//         if NetComGDErrorHandler.ResponseHasError(NetComGDMethod::PostFile, ResponseText) then begin
//             // NetComGDErrorHandler.GetError(GDIMethod, GDIProblem, ErrorValue);
//             // GDIQueueHandler.Update(QueueID, GDIStatus::"To Handle", GDIMethod, GDIProblem, MediaID, '', ErrorValue);
//             // Commit();
//             exit;
//         end;

//         ResponseJson.ReadFrom(ResponseText);
//         Message('BUG File Upload Response = %1', ResponseText);
//         if NetComGDJsonHelper.TryGetTextValueFromJson(FileID, ResponseJson, NetComGDTokens.IdTok()) then;
//         if FileID = '' then begin
//             // GDIQueueHandler.Update(
//             //     QueueID, GDIStatus::"To Handle", 'PostFile', 'MissingFileID', MediaID, '', ResponseText);
//             // Commit();
//             exit;
//         end;

//         UpdateGDMediaFileID(NetComCustomerPriceService."Customer No.", FileID);
//         // GDIQueueHandler.Update(
//         //     QueueID, GDIStatus::Handled, 'PostFile', 'Undefined', MediaID, FileID, '');
//         Commit();

//         //PatchMetadata(GDIJsonHelper.CreateSimpleJson(GDITokens.Name(), FileName), FileID, MediaID);
//         PatchMetadata(NetComGDJsonHelper.CreateSimpleJson(NetComGDTokens.Title(), FileName), FileID, MediaID);
//     end;

//     local procedure UpdateGDMediaFileID(CustomerNo: Code[20]; FileID: Text)
//     var
//         NetComCustomerPriceService: Record "NetCom Customer Price Service";
//     begin
//         NetComCustomerPriceService.Get(CustomerNo);
//         NetComCustomerPriceService.Validate("GD FileID", FileID);
//         NetComCustomerPriceService.Modify(true);
//     end;


//     // procedure CreateWithLink(var NewMediaID: Integer; EntityTypeID: Integer; EntityID: Text)
//     // var
//     //     // GDILinksHandler: Codeunit "GDI Links Handler";
//     //     // GDIErrorHandler: Codeunit "GDI Error Handler";
//     //     MediaInStream: InStream;
//     //     ClientFileName: Text;
//     // begin
//     //     //STEP2 (upload)
//     //     // if not File.UploadIntoStream(DialogTitleUploadTxt, '', UploadFileFilterTxt, ClientFileName, MediaInStream) then
//     //     //     GDIErrorHandler.ThrowFileUploadErr(ClientFileName);

//     //     // NewMediaID := CreateGoogleDriveMedia(MediaInStream, ClientFileName, '');
//     //     // if EntityTypeID <> 0 then
//     //     //     GDILinksHandler.CreateLink(NewMediaID, EntityTypeID, EntityID);
//     //     CreateOnGoogleDrive(MediaInStream, ClientFileName, NewMediaID);
//     // end;

//     // procedure CreateNetCom(var NewMediaID: Integer)
//     // var
//     // // GDILinksHandler: Codeunit "GDI Links Handler";
//     // // GDIErrorHandler: Codeunit "GDI Error Handler";
//     // begin
//     //     //STEP2 (upload)
//     //     // if not File.UploadIntoStream(DialogTitleUploadTxt, '', UploadFileFilterTxt, ClientFileName, MediaInStream) then
//     //     //     GDIErrorHandler.ThrowFileUploadErr(ClientFileName);

//     //     // NewMediaID := CreateGoogleDriveMedia(MediaInStream, ClientFileName, '');
//     //     // if EntityTypeID <> 0 then
//     //     //     GDILinksHandler.CreateLink(NewMediaID, EntityTypeID, EntityID);
//     //     CreateOnGoogleDrive(MediaInStream, NewMediaID);
//     // end;

//     // procedure CreateOnGoogleDrive(var MediaInStream: InStream; FileName: Text; MediaID: Integer)
//     // var
//     //     GDISetupMgt: Codeunit "GDI Setup Mgt.";
//     //     GDIRequestHandler: Codeunit "GDI Request Handler";
//     //     GDIErrorHandler: Codeunit "GDI Error Handler";
//     //     GDIQueueHandler: Codeunit "GDI Queue Handler";
//     //     GDIJsonHelper: Codeunit "GDI Json Helper";
//     //     GDITokens: Codeunit "GDI Tokens";
//     //     ResponseJson: JsonObject;
//     //     GDIMethod: Enum "GDI Method";
//     //     GDIProblem: Enum "GDI Problem";
//     //     GDIStatus: Enum "GDI Status";
//     //     ResponseText: Text;
//     //     ErrorValue: Text;
//     //     FileID: Text;

//     //     QueueID: Integer;
//     // begin
//     //     //STEP3 (Upload)
//     //     if FileName = '' then
//     //         GDIErrorHandler.ThrowFileNameMissingErr();

//     //     // if MediaID = 0 then
//     //     //     GDIErrorHandler.ThrowMediaIDMissingErr();

//     //     // QueueID := GDIQueueHandler.Create(GDIMethod::PostFile, GDIProblem::Undefined, MediaID, '');
//     //     // Commit();

//     //     GDISetupMgt.Authorize(GDIMethod::PostFile);
//     //     // GDISetupMgt.GetError(GDIMethod, GDIProblem, ErrorValue);
//     //     // if ErrorValue <> '' then begin
//     //     //     GDIQueueHandler.Update(QueueID, GDIStatus::"To Handle", GDIMethod, GDIProblem, MediaID, '', ErrorValue);
//     //     //     Commit();
//     //     //     exit;
//     //     // end;

//     //     ResponseText := GDIRequestHandler.PostFile(MediaInStream);
//     //     if GDIErrorHandler.ResponseHasError(GDIMethod::PostFile, ResponseText) then begin
//     //         GDIErrorHandler.GetError(GDIMethod, GDIProblem, ErrorValue);
//     //         GDIQueueHandler.Update(QueueID, GDIStatus::"To Handle", GDIMethod, GDIProblem, MediaID, '', ErrorValue);
//     //         Commit();
//     //         exit;
//     //     end;

//     //     ResponseJson.ReadFrom(ResponseText);
//     //     Message('BUG File Upload Response = %1', ResponseText);
//     //     if GDIJsonHelper.TryGetTextValueFromJson(FileID, ResponseJson, GDITokens.IdTok()) then;
//     //     if FileID = '' then begin
//     //         GDIQueueHandler.Update(
//     //             QueueID, GDIStatus::"To Handle", GDIMethod::PostFile, GDIProblem::MissingFileID, MediaID, '', ResponseText);
//     //         Commit();
//     //         exit;
//     //     end;

//     //     UpdateGoogleDriveMediaFileID(MediaID, FileID);
//     //     GDIQueueHandler.Update(
//     //         QueueID, GDIStatus::Handled, GDIMethod::PostFile, GDIProblem::Undefined, MediaID, FileID, '');
//     //     Commit();

//     //     //PatchMetadata(GDIJsonHelper.CreateSimpleJson(GDITokens.Name(), FileName), FileID, MediaID);
//     //     PatchMetadata(GDIJsonHelper.CreateSimpleJson(GDITokens.Title(), FileName), FileID, MediaID);
//     // end;

//     // procedure CreateOnGoogleDrive(MediaID: Integer)
//     // var
//     //     TempBlob: Codeunit "Temp Blob";
//     //     MediaInStream: InStream;
//     //     FileName: Text;
//     // begin
//     //     ReadFileFromMedia(TempBlob, FileName, MediaID);
//     //     TempBlob.CreateInStream(MediaInStream);
//     //     CreateOnGoogleDrive(MediaInStream, FileName, MediaID);
//     // end;

//     // procedure Delete(MediaID: Integer; EntityTypeID: Integer; EntityID: Text)
//     // var
//     //     GDILinksHandler: Codeunit "GDI Links Handler";
//     //     SelectedOption: Integer;
//     // begin
//     //     if EntityTypeID = 0 then begin
//     //         if Confirm(DeleteConfirmTxt, true) then
//     //             Delete(MediaID);
//     //     end else
//     //         if GDILinksHandler.MediaHasSeveralLinks(MediaID, EntityTypeID, EntityID) then begin
//     //             SelectedOption := StrMenu(DeleteMenuOptionsTxt, 1, DeleteMenuLabelTxt);
//     //             case SelectedOption of
//     //                 1:
//     //                     GDILinksHandler.DeleteLink(MediaID, EntityTypeID, EntityID);
//     //                 2:
//     //                     Delete(MediaID);
//     //             end;
//     //         end else
//     //             if Confirm(DeleteConfirmTxt, true) then
//     //                 Delete(MediaID);
//     // end;

//     // procedure Delete(MediaID: Integer)
//     // var
//     //     GDIMedia: Record "GDI Media";
//     //     FileID: Text;
//     // begin
//     //     GDIMedia.Get(MediaID);
//     //     FileID := GDIMedia.FileID;
//     //     GDIMedia.Delete(true);
//     //     DeleteFromGoogleDrive(MediaID, FileID);
//     // end;

//     // procedure DeleteFromGoogleDrive(MediaID: Integer; FileID: Text)
//     // var
//     //     GDISetupMgt: Codeunit "GDI Setup Mgt.";
//     //     GDIRequestHandler: Codeunit "GDI Request Handler";
//     //     GDIErrorHandler: Codeunit "GDI Error Handler";
//     //     GDIQueueHandler: Codeunit "GDI Queue Handler";
//     //     GDIMethod: Enum "GDI Method";
//     //     GDIProblem: Enum "GDI Problem";
//     //     GDIStatus: Enum "GDI Status";
//     //     ResponseText: Text;
//     //     ErrorValue: Text;
//     //     QueueID: Integer;
//     // begin
//     //     if FileID = '' then begin
//     //         GDIQueueHandler.Create(GDIStatus::"To Handle", GDIMethod::DeleteFile, GDIProblem::MissingFileID, MediaID, '');
//     //         Commit();
//     //         exit;
//     //     end;
//     //     QueueID := GDIQueueHandler.Create(GDIMethod::DeleteFile, GDIProblem::Undefined, MediaID, FileID);
//     //     Commit();

//     //     GDISetupMgt.Authorize(GDIMethod::DeleteFile);
//     //     GDISetupMgt.GetError(GDIMethod, GDIProblem, ErrorValue);
//     //     if ErrorValue <> '' then begin
//     //         GDIQueueHandler.Update(QueueID, GDIStatus::"To Handle", GDIMethod, GDIProblem, MediaID, FileID, ErrorValue);
//     //         Commit();
//     //         exit;
//     //     end;

//     //     ResponseText := GDIRequestHandler.DeleteFile(FileID);
//     //     if GDIErrorHandler.ResponseHasError(GDIMethod::DeleteFile, ResponseText) then begin
//     //         GDIErrorHandler.GetError(GDIMethod, GDIProblem, ErrorValue);
//     //         GDIQueueHandler.Update(QueueID, GDIStatus::"To Handle", GDIMethod, GDIProblem, MediaID, FileID, ErrorValue);
//     //         Commit();
//     //         exit;
//     //     end;

//     //     GDIQueueHandler.Update(QueueID, GDIStatus::Handled, GDIMethod::DeleteFile, GDIProblem::Undefined, MediaID, FileID, '');
//     //     Commit();
//     // end;

//     // procedure Download(MediaID: Integer)
//     // var
//     //     TempBlob: Codeunit "Temp Blob";
//     //     MediaInStream: InStream;
//     //     FileName: Text;
//     // begin
//     //     ReadFileFromMedia(TempBlob, FileName, MediaID);
//     //     TempBlob.CreateInStream(MediaInStream);
//     //     File.DownloadFromStream(MediaInStream, DialogTitleDownloadTxt, '', '', FileName);
//     // end;

//     // procedure Get(var GDIMedia: Record "GDI Media"; NotifyOnly: Boolean)
//     // var
//     //     GDIMediaInfo: Record "GDI Media Info";
//     //     TenantMedia: Record "Tenant Media";
//     //     GDICacheCleaner: Codeunit "GDI Cache Cleaner";
//     //     GDIErrorHandler: Codeunit "GDI Error Handler";
//     //     GDITokens: Codeunit "GDI Tokens";
//     //     GDIMethod: Enum "GDI Method";
//     //     MediaInStream: InStream;
//     //     ErrorText: Text;
//     // begin
//     //     if GDIMedia.FileContent.HasValue() then
//     //         if not Confirm(GetConfirmTxt, false) then
//     //             exit;

//     //     Get(MediaInStream, ErrorText, GDIMedia.FileID);
//     //     if GDIErrorHandler.ResponseHasError(GDIMethod::GetFile, ErrorText) then begin
//     //         GDIErrorHandler.SetRecordID(GDIMedia.RecordId);
//     //         GDIErrorHandler.HandleCurrentError(NotifyOnly)
//     //     end else begin
//     //         GDIMedia.FileContent.ImportStream(MediaInStream, GDIMedia.FileName, GDITokens.MimeTypeJpeg());
//     //         GDIMedia.Modify(true);
//     //         if GDIMediaInfo.Get(GDIMedia.ID) then begin
//     //             TenantMedia.Get(GDIMedia.FileContent.MediaId);
//     //             TenantMedia.CalcFields(Content);
//     //             GDIMediaInfo.Validate(FileSize, TenantMedia.Content.Length / 1048576);
//     //             GDIMediaInfo.Validate(Rank, 100);
//     //             GDIMediaInfo.Modify(true);
//     //             GDICacheCleaner.ClearCacheOnDemand(GDIMediaInfo.FileSize, GDIMediaInfo.MediaID);
//     //         end;
//     //     end;
//     // end;

//     // procedure Get(var MediaInStream: InStream; var ErrorText: Text; FileID: Text)
//     // var
//     //     GDISetupMgt: Codeunit "GDI Setup Mgt.";
//     //     GDIRequestHandler: Codeunit "GDI Request Handler";
//     //     GDIJsonHelper: Codeunit "GDI Json Helper";
//     //     GDITokens: Codeunit "GDI Tokens";
//     //     GDIMethod: Enum "GDI Method";
//     //     GDIProblem: Enum "GDI Problem";
//     // begin
//     //     if FileID = '' then begin
//     //         ErrorText := GDIJsonHelper.CreateSimpleJson(GDITokens.ErrorTok(), Format(GDIProblem::MissingFileID));
//     //         exit;
//     //     end;

//     //     GDISetupMgt.Authorize(GDIMethod::GetFile);
//     //     GDIRequestHandler.GetMedia(MediaInStream, FileID);
//     //     ErrorText := GDIRequestHandler.GetErrorText();
//     // end;

//     // procedure Update(MediaID: Integer)
//     // var
//     //     GDIErrorHandler: Codeunit "GDI Error Handler";
//     //     MediaInStream: InStream;
//     //     ClientFileName: Text;
//     // begin
//     //     if not File.UploadIntoStream(DialogTitleUploadTxt, '', UploadFileFilterTxt, ClientFileName, MediaInStream) then
//     //         GDIErrorHandler.ThrowFileUploadErr(ClientFileName);

//     //     UpdateGoogleDriveMedia(MediaInStream, ClientFileName, MediaID);
//     //     UpdateOnGoogleDrive(MediaInStream, ClientFileName, MediaID);
//     // end;

//     // procedure UpdateFileName(NewFileName: Text; MediaID: Integer)
//     // var
//     //     GDIMedia: Record "GDI Media";
//     //     GDIJsonHelper: Codeunit "GDI Json Helper";
//     //     GDITokens: Codeunit "GDI Tokens";
//     // begin
//     //     GDIMedia.Get(MediaID);
//     //     if NewFileName = '' then
//     //         NewFileName := GDIMedia.FileName;
//     //     PatchMetadata(
//     //         //GDIJsonHelper.CreateSimpleJson(GDITokens.Name(), NewFileName), GDIMedia.FileID, GDIMedia.ID);
//     //         GDIJsonHelper.CreateSimpleJson(GDITokens.Title(), NewFileName), GDIMedia.FileID, GDIMedia.ID);
//     // end;

//     // procedure UpdateOnGoogleDrive(var MediaInStream: InStream; FileName: Text; MediaID: Integer)
//     // var
//     //     GDISetupMgt: Codeunit "GDI Setup Mgt.";
//     //     GDIRequestHandler: Codeunit "GDI Request Handler";
//     //     GDIErrorHandler: Codeunit "GDI Error Handler";
//     //     GDIQueueHandler: Codeunit "GDI Queue Handler";
//     //     GDIJsonHelper: Codeunit "GDI Json Helper";
//     //     GDITokens: Codeunit "GDI Tokens";
//     //     GDIMethod: Enum "GDI Method";
//     //     GDIProblem: Enum "GDI Problem";
//     //     GDIStatus: Enum "GDI Status";
//     //     ResponseText: Text;
//     //     ErrorValue: Text;
//     //     FileID: Text;
//     //     QueueID: Integer;
//     // begin
//     //     if FileName = '' then
//     //         GDIErrorHandler.ThrowFileNameMissingErr();

//     //     if MediaID = 0 then
//     //         GDIErrorHandler.ThrowFileIDMissingErr();

//     //     FileID := GetGoogleDriveMediaFileID(MediaID);
//     //     if FileID = '' then begin
//     //         GDIQueueHandler.Create(GDIStatus::"To Handle", GDIMethod::PatchFile, GDIProblem::MissingFileID, MediaID, '');
//     //         Commit();
//     //         exit;
//     //     end;
//     //     QueueID := GDIQueueHandler.Create(GDIMethod::PatchFile, GDIProblem::Undefined, MediaID, FileID);
//     //     Commit();

//     //     GDISetupMgt.Authorize(GDIMethod::PatchFile);
//     //     GDISetupMgt.GetError(GDIMethod, GDIProblem, ErrorValue);
//     //     if ErrorValue <> '' then begin
//     //         GDIQueueHandler.Update(QueueID, GDIStatus::"To Handle", GDIMethod, GDIProblem, MediaID, FileID, ErrorValue);
//     //         Commit();
//     //         exit;
//     //     end;

//     //     ResponseText := GDIRequestHandler.PatchFile(MediaInStream, FileID);
//     //     if GDIErrorHandler.ResponseHasError(GDIMethod::PatchFile, ResponseText) then begin
//     //         GDIErrorHandler.GetError(GDIMethod, GDIProblem, ErrorValue);
//     //         GDIQueueHandler.Update(QueueID, GDIStatus::"To Handle", GDIMethod, GDIProblem, MediaID, FileID, ErrorValue);
//     //         Commit();
//     //         exit;
//     //     end;
//     //     GDIQueueHandler.Update(QueueID, GDIStatus::Handled, GDIMethod::PatchFile, GDIProblem::Undefined, MediaID, FileID, '');
//     //     Commit();

//     //     //PatchMetadata(GDIJsonHelper.CreateSimpleJson(GDITokens.Name(), FileName), FileID, MediaID);
//     //     PatchMetadata(GDIJsonHelper.CreateSimpleJson(GDITokens.Title(), FileName), FileID, MediaID);
//     // end;

//     // procedure UpdateOnGoogleDrive(MediaID: Integer)
//     // var
//     //     TempBlob: Codeunit "Temp Blob";
//     //     MediaInStream: InStream;
//     //     FileName: Text;
//     // begin
//     //     ReadFileFromMedia(TempBlob, FileName, MediaID);
//     //     TempBlob.CreateInStream(MediaInStream);
//     //     UpdateOnGoogleDrive(MediaInStream, FileName, MediaID);
//     // end;

//     procedure PatchMetadata(NewMetadata: Text; FileID: Text; MediaID: Integer)
//     var
//         NetComGDConnector: Codeunit "NetCom GD Connector";
//         // GDISetupMgt: Codeunit "GDI Setup Mgt.";
//         GDIRequestHandler: Codeunit "NetCom GD Request Handler";
//         // GDIQueueHandler: Codeunit "GDI Queue Handler";
//         NetComGDErrorHandler: Codeunit "NetCom GD Error Handler";
//         GDIMethod: Enum "NetCom GD Method";
//         // GDIProblem: Enum "GDI Problem";
//         // GDIStatus: Enum "GDI Status";
//         ResponseText: Text;
//         ErrorValue: Text;
//         QueueID: Integer;
//     begin
//         //STEP4 (Upload)
//         if NewMetadata = '' then
//             NetComGDErrorHandler.ThrowFileNameMissingErr(); // TEMP

//         if MediaID = 0 then
//             NetComGDErrorHandler.ThrowMediaIDMissingErr();

//         if FileID = '' then begin
//             // GDIQueueHandler.Create(GDIStatus::"To Handle", GDIMethod::PatchMetadata, GDIProblem::MissingFileID, MediaID, '');
//             // Commit();
//             exit;
//         end;
//         // QueueID := GDIQueueHandler.Create(GDIMethod::PatchMetadata, GDIProblem::Undefined, MediaID, FileID);
//         Commit();

//         NetComGDConnector.Authorize(GDIMethod::PatchMetadata);
//         NetComGDConnector.GetError(GDIMethod, ErrorValue);
//         if ErrorValue <> '' then begin
//             // GDIQueueHandler.Update(QueueID, GDIStatus::"To Handle", GDIMethod, GDIProblem, MediaID, FileID, ErrorValue);
//             // Commit();
//             exit;
//         end;

//         ResponseText := GDIRequestHandler.PatchMetadata(NewMetadata, FileID);
//         Message('BUG\\File ID: %1\Response: %2', FileID, ResponseText);

//         NewMetadata := '{' +
//                             '"parents": [' +
//                                 '{' +
//                                     '"id": "1hztIuWiJQhg-aIBy3qrrVnJEIORqgL3u"' +
//                                 '}' +
//                             ']' +
//                         '}';
//         ResponseText := GDIRequestHandler.PatchMetadata(NewMetadata, FileID);
//         // Message('BUG2\\File ID: %1\Response: %2', FileID, ResponseText);

//         if NetComGDErrorHandler.ResponseHasError(GDIMethod::PatchMetadata, ResponseText) then begin
//             // GDIErrorHandler.GetError(GDIMethod, GDIProblem, ErrorValue);
//             NetComGDErrorHandler.GetError(GDIMethod, ErrorValue);
//             // GDIQueueHandler.Update(QueueID, GDIStatus::"To Handle", GDIMethod, GDIProblem, MediaID, FileID, ErrorValue);
//             Commit();
//             exit;
//         end;

//         // GDIQueueHandler.Update(QueueID, GDIStatus::Handled, GDIMethod::PatchMetadata, GDIProblem::Undefined, MediaID, FileID, '');
//         // Commit();
//         exit;
//     end;

//     // procedure ReadFileFromMedia(var TempBlob: codeunit "Temp Blob"; var FileName: Text; MediaID: Integer)
//     // var
//     //     GDIMedia: Record "GDI Media";
//     //     MediaOutStream: OutStream;
//     // begin
//     //     Clear(TempBlob); // clears reference only
//     //     GDIMedia.Get(MediaID);
//     //     FileName := GDIMedia.FileName;
//     //     TempBlob.CreateOutStream(MediaOutStream);
//     //     GDIMedia.FileContent.ExportStream(MediaOutStream);
//     // end;

//     // procedure RunMediaPage(EntityTypeID: Integer; EntityID: Text; Caption: Text)
//     // var
//     //     GDIMedia: Record "GDI Media";
//     //     GDILinksHandler: Codeunit "GDI Links Handler";
//     //     GDIMediaPage: Page "GDI Media";
//     // begin
//     //     GDIMedia.SetFilter(ID, GDILinksHandler.CreateSelectionFilter(EntityTypeID, EntityID)); // FilterGroup 0
//     //     GDIMediaPage.SetTableView(GDIMedia);
//     //     GDIMediaPage.SetEntity(EntityTypeID, EntityID);
//     //     GDIMediaPage.UpdateViews(EntityTypeID, EntityID);
//     //     if Caption <> '' then
//     //         GDIMediaPage.Caption := Caption;
//     //     GDIMediaPage.Run();
//     // end;

//     // procedure UpdateViewedByEntity(MediaID: Integer)
//     // var
//     //     GDIMediaInfo: Record "GDI Media Info";
//     // begin
//     //     if GDIMediaInfo.Get(MediaID) then begin
//     //         GDIMediaInfo.ViewedByEntity += 1;
//     //         GDIMediaInfo.LastViewedByEntity := CurrentDateTime;
//     //         GDIMediaInfo.Modify(true);
//     //     end;
//     // end;

//     // local procedure CreateGoogleDriveMedia(MediaInStream: InStream; FileName: Text; FileID: Text): Integer
//     // var
//     //     GDIMedia: Record "GDI Media";
//     //     GDIMediaInfo: Record "GDI Media Info";
//     //     TenantMedia: Record "Tenant Media";
//     //     GDICacheCleaner: Codeunit "GDI Cache Cleaner";
//     //     GDITokens: Codeunit "GDI Tokens";
//     // begin
//     //     GDIMedia.Init();
//     //     GDIMedia.Validate(FileID, FileID);
//     //     GDIMedia.Validate(FileName, FileName);
//     //     GDIMedia.FileContent.ImportStream(MediaInStream, FileName, GDITokens.MimeTypeJpeg());
//     //     GDIMedia.Insert(true);

//     //     TenantMedia.Get(GDIMedia.FileContent.MediaId);
//     //     TenantMedia.CalcFields(Content);
//     //     GDIMediaInfo.Init();
//     //     GDIMediaInfo.Validate(MediaID, GDIMedia.ID);
//     //     GDIMediaInfo.Validate(FileSize, TenantMedia.Content.Length / 1048576);
//     //     GDIMediaInfo.Validate(Rank, 100);
//     //     GDIMediaInfo.Insert(true);
//     //     GDICacheCleaner.ClearCacheOnDemand(GDIMediaInfo.FileSize, GDIMediaInfo.MediaID);
//     //     exit(GDIMedia.ID);
//     // end;

//     // local procedure GetGoogleDriveMediaFileID(MediaID: Integer): Text
//     // var
//     //     GDIMedia: Record "GDI Media";
//     // begin
//     //     if GDIMedia.Get(MediaID) then
//     //         exit(GDIMedia.FileID);
//     //     exit('');
//     // end;

//     // local procedure UpdateGoogleDriveMedia(MediaInStream: InStream; FileName: Text; ID: Integer)
//     // var
//     //     GDIMedia: Record "GDI Media";
//     //     GDIMediaInfo: Record "GDI Media Info";
//     //     TenantMedia: Record "Tenant Media";
//     //     GDICacheCleaner: Codeunit "GDI Cache Cleaner";
//     //     GDITokens: Codeunit "GDI Tokens";
//     //     OldFileSize: Decimal;
//     // begin
//     //     GDIMedia.Get(ID);
//     //     GDIMedia.Validate(FileName, FileName);
//     //     GDIMedia.FileContent.ImportStream(MediaInStream, FileName, GDITokens.MimeTypeJpeg());
//     //     GDIMedia.Modify(true);

//     //     TenantMedia.Get(GDIMedia.FileContent.MediaId);
//     //     TenantMedia.CalcFields(Content);
//     //     GDIMediaInfo.Get(GDIMedia.ID);
//     //     OldFileSize := GDIMediaInfo.FileSize;
//     //     GDIMediaInfo.Validate(FileSize, TenantMedia.Content.Length / 1048576);
//     //     GDIMediaInfo.Validate(Rank, 100);
//     //     Clear(GDIMediaInfo.Stars);
//     //     GDIMediaInfo.Modify(true);
//     //     if OldFileSize < GDIMediaInfo.FileSize then
//     //         GDICacheCleaner.ClearCacheOnDemand(GDIMediaInfo.FileSize, GDIMediaInfo.MediaID);
//     // end;

//     // local procedure UpdateGoogleDriveMediaFileID(MediaID: Integer; FileID: Text)
//     // var
//     //     GDIMedia: Record "GDI Media";
//     // begin
//     //     GDIMedia.Get(MediaID);
//     //     GDIMedia.Validate(FileID, FileID);
//     //     GDIMedia.Modify(true);
//     // end;

//     // procedure Deprecated_GetMetadata(FileID: Text): Text
//     // var
//     //     GDISetupMgt: Codeunit "GDI Setup Mgt.";
//     //     GDIRequestHandler: Codeunit "GDI Request Handler";
//     //     GDIErrorHandler: Codeunit "GDI Error Handler";
//     //     GDIMethod: Enum "GDI Method";
//     //     ResponseText: Text;
//     // begin
//     //     // INFO: we don't need this function at the moment
//     //     // when the function is added it should be aligned with Get.
//     //     if FileID = '' then
//     //         GDIErrorHandler.ThrowFileIDMissingErr();

//     //     GDISetupMgt.Authorize(GDIMethod::GetMetadata);
//     //     ResponseText := GDIRequestHandler.Deprecated_GetMetadata(FileID);
//     //     exit(ResponseText);
//     // end;

//     var
//         DialogTitleUploadTxt: Label 'File Upload'; // duplicate. shall it be here?
//         DialogTitleDownloadTxt: Label 'File Download'; // shall it be here?
//         DeleteConfirmTxt: Label 'Do you really want to delete this media?';
//         DeleteMenuOptionsTxt: Label 'Delete the link only (recommended),Delete the media and links';
//         DeleteMenuLabelTxt: Label 'Warning! This media has links to other entities. Please, select an option:';
//         GetConfirmTxt: Label 'The image is already in the database. Do you want to pull the last version from Google Drive?';
//         UploadFileFilterTxt: Label 'JPEG|*.jpg;*.jpeg';
// }