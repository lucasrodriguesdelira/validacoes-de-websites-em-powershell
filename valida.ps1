$URLListFile = "sites.txt"  
$URLList = Get-Content $URLListFile -ErrorAction SilentlyContinue 
$Result = @()
$msg = Write-Output "O site está incorreto.`n                ou`nÉ impossível acessá-lo."
Foreach($Uri in $URLList) {
    $data = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::tls12
    $time = try{
        $request = $null
        $result1 = Measure-Command { $request = Invoke-WebRequest -Uri $uri -TimeoutSec 60 -UseBasicParsing}
        $result1.Milliseconds
    }
    catch {
        $request = $_.Exception.Response
        $time = -1
    }
    $result += [PSCustomObject] @{
        Time = Get-Date;
        Uri = $uri;
        StatusCode = [int] $request.StatusCode;
        StatusDescription = $request.StatusDescription;
        ResponseLength = $request.RawContentLength;
        TimeTaken =  $time;
        date = $data
    }
}
if($null -ne $result){
    $Outputreport = "<!DOCTYPE html>
<html lang='pt-br'>
    <head>
        <meta charset='UTF-8'>
        <title> MIDDLEWARE | WEBSITES </title>
        <style type='text/css'></style>
    </head>
    <style>  
    td {
        border: 2px solid #ccc;
        border-radius: 5px;
    }
    </style>
    <body align='center'>
        <font size='5' face='Tahoma, Verdana, Arial, Helvetica, sans-serif' color='red'>
            <h3 align='center'> WEBSITES CHECKLIST </h3>
        </font>
        <div align='center'>
            <Table border=0 cellpadding=1 cellspacing=5>
                <TR bgcolor=red align=center>
                    <TD><FONT COLOR=white> URL </TD>
                    <TD><FONT COLOR=white> STATUS CODE </TD>
                    <TD><FONT COLOR=white> STATUS </TD>
                    <TD><FONT COLOR=white> RESPONSE LENGT </TD>
                    <TD><FONT COLOR=white> TIME TAKEN </TD>
                    <TD><FONT COLOR=white> DATA </TD>
                </TR>"
    Foreach($Entry in $Result) {
        if(
            $Entry.StatusCode -eq 200 -or
            $Entry.StatusCode -eq 401 -or
            $Entry.StatusCode -eq 403
        )
        {
            $Outputreport += "
                <TR>
                    <TD> $($Entry.uri) </TD>
                    <TD align='center'> $($Entry.StatusCode) </TD>
                    <TD align='center' bgcolor=green><FONT COLOR=white> Running </TD>
                    <TD align='center'> $($Entry.ResponseLength) </TD>
                    <TD align='center'> $($Entry.TimeTaken) </TD>
                    <TD align='center'> $($Entry.date) </TD>
                </TR>"
        }
        elseif ($Entry.StatusCode -eq 0) {
            $Outputreport += "
                <TR>
                    <TD> $($Entry.uri) </TD>
                    <TD align='center'> ---- </TD>
                    <TD align='center' bgcolor=yellow><span title='$msg'> Invalid </span></TD>
                    <TD align='center'> ---- </TD>
                    <TD align='center'> ---- </TD>
                    <TD align='center'> $($Entry.date) </TD>
                </TR>"
        }
        else {
            $Outputreport += "
                <TR>
                    <TD> $($Entry.uri) </TD>
                    <TD align='center'> $($Entry.StatusCode) </TD>
                    <TD align='center' bgcolor=red><FONT COLOR=white> $($Entry.StatusDescription) </TD>
                    <TD align='center'> ---- </TD>
                    <TD align='center'> ---- </TD>
                    <TD align='center'> $($Entry.date) </TD>
                </TR>"
        }
    }
    $Outputreport += "
            </Table>
        </div>
    </body>
</html>"}
$Outputreport | out-file index.html
