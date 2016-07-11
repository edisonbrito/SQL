--Step 1: Configure Email Setting:
sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'Ole Automation Procedures', 1;  
GO  
RECONFIGURE;  
GO   

--Step 2: Create Store Procedure To Send Email:

CREATE PROCEDURE [dbo].[sp_send_mail]  
        @from varchar(500) ,  
        @to varchar(500) ,  
        @subject varchar(500),  
        @body varchar(4000) ,  
        @bodytype varchar(10),  
        @output_mesg varchar(10) output,  
        @output_desc varchar(1000) output  
AS  
DECLARE @imsg int  
DECLARE @hr int  
DECLARE @source varchar(255)  
DECLARE @description varchar(500)  
  
EXEC @hr = sp_oacreate 'cdo.message', @imsg out  
  
EXEC @hr = sp_oasetproperty @imsg,  
'configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendusing").value','2'  
  
--SMTP Server  
EXEC @hr = sp_oasetproperty @imsg,   
  'configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserver").value',   
  'smtp.gmail.com'   
  
--UserName  
EXEC @hr = sp_oasetproperty @imsg,   
  'configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendusername").value',   
  'sender@gmail.com'   
  
--Password  
EXEC @hr = sp_oasetproperty @imsg,   
  'configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendpassword").value',   
  'xxxxxx'   
  
--UseSSL  
EXEC @hr = sp_oasetproperty @imsg,   
  'configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpusessl").value',   
  'True'   
  
--PORT   
EXEC @hr = sp_oasetproperty @imsg,   
  'configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserverport").value',   
  '465'   
  
--Requires Aunthentication None(0) / Basic(1)  
EXEC @hr = sp_oasetproperty @imsg,   
  'configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate").value',   
  '1'   
  
EXEC @hr = sp_oamethod @imsg, 'configuration.fields.update', null  
EXEC @hr = sp_oasetproperty @imsg, 'to', @to  
EXEC @hr = sp_oasetproperty @imsg, 'from', @from  
EXEC @hr = sp_oasetproperty @imsg, 'subject', @subject  
  
-- if you are using html e-mail, use 'htmlbody' instead of 'textbody'.  
  
EXEC @hr = sp_oasetproperty @imsg, @bodytype, @body  
EXEC @hr = sp_oamethod @imsg, 'send', null  
  
SET @output_mesg = 'Success'  
  
-- sample error handling.  
IF @hr <>0   
    SELECT @hr  
    BEGIN  
        EXEC @hr = sp_oageterrorinfo null, @source out, @description out  
        IF @hr = 0  
        BEGIN  
            --set @output_desc = ' source: ' + @source  
            set @output_desc =  @description  
        END  
    ELSE  
    BEGIN  
        SET @output_desc = ' sp_oageterrorinfo failed'  
    END  
    IF not @output_desc is NULL  
            SET @output_mesg = 'Error'  
END  
EXEC @hr = sp_oadestroy @imsg  

--Step 3: Execute SP

DECLARE @out_desc varchar(1000),  
        @out_mesg varchar(10)  
  
EXEC sp_send_mail 'sender@gmail.com',  
    'receiver@gmail.com',  
    'Hii',   
    '<b>Sending Test Mail</b>',  
    'htmlbody', @output_mesg = @out_mesg output, @output_desc = @out_desc output  
  
PRINT @out_mesg  
PRINT @out_desc