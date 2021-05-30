$URLListFile = "sites.txt"  
$URLList = Get-Content $URLListFile -ErrorAction SilentlyContinue 
$Result = @()
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
    </head>
    <body align='center'>
        <font size='5' face='Tahoma, Verdana, Arial, Helvetica, sans-serif' color='red'>
            <h3> WEBSITES CHECKLIST </h3>
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
                <TR align='center'>
                    <TD> $($Entry.uri) </TD>
                    <TD> $($Entry.StatusCode) </TD>
                    <TD bgcolor=green><FONT COLOR=white> RUNNING </TD>
                    <TD> $($Entry.ResponseLength) </TD>
                    <TD> $($Entry.TimeTaken) </TD>
                    <TD> $($Entry.date) </TD>
                </TR>"
        }
        elseif ($Entry.StatusCode -eq 0) {
            $Outputreport += "
                <TR align='center'>
                    <TD> $($Entry.uri) </TD>
                    <TD> $($Entry.StatusCode) </TD>
                    <TD bgcolor=red><FONT COLOR=white title='O site esta incorreto ou eh impossivel acessa-lo!!!'> INVALID SITE </TD>
                    <TD> $($Entry.ResponseLength) </TD>
                    <TD> $($Entry.timetaken) </TD>
                    <TD> $($Entry.date) </TD>
                </TR>"
        }
        else {
            $Outputreport += "
                <TR align='center'>
                    <TD> $($Entry.uri) </TD>
                    <TD> $($Entry.StatusCode) </TD>
                    <TD bgcolor=red><FONT COLOR=white> $($Entry.StatusDescription) </TD>
                    <TD> $($Entry.ResponseLength) </TD>
                    <TD> $($Entry.timetaken) </TD>
                    <TD> $($Entry.date) </TD>
                </TR>"
        }
    }
    $Outputreport += "
            </Table>
        </div>
    </body>
</html>"}
$Outputreport | out-file index.html
