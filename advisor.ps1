using namespace System.Collections.Generic
$_scriptVersion = "0.2.4-01";

## input params  ================================================
## put SubscriptionsId here
$subscriptionList = "241088f5-a1f0-4bb5-a158-f3848382cd01";

##
$applyAdvisorFilter = $false;  ## without filter
$applyAdvisorFilter = $true;  ## with filter comment if filter no need


$advisorFilter = "Category eq 'Cost'";

## end of parameters =================

## $advisorCategory = "Cost"

## output file path
$cvsFilePathTemplate = "";       ## left empty to ouput path near the script (same folder)
#$cvsFilePathTemplate = "C:\Temp";       ## put here path (folder) where script will be save csv file of result
## ===========================================================================

if ([string]::IsNullOrWhiteSpace($cvsFilePathTemplate)) {
  $cvsFilePathTemplate = $PSScriptRoot;
  Write-Warning "The result file (.csv) will be save into folder: $($cvsFilePathTemplate)"
}
else {
  if (-not (Test-Path -Path $cvsFilePathTemplate)) {
    Write-Error -Message "The path for result csv file not exist! Exiting!";
    Exit;
  }
} 

## prepare date part of name
$csvReportDate = (Get-Date).tostring("yyyyMMdd-HHmm");


$arrSubscription = [list[string]]::New();    ## create list/array
$arrSubscription.AddRange([string[]]($subscriptionList -split ',').Trim());  #translate and trim spaces of input parameter into array

$htSubscriptionAdvisorRecomendations = @{};  ## create hashtable

$AzAccessToken = Get-AzAccessToken           ## token

Write-Host "AccessToken Expired: $($AzAccessToken.ExpiresOn)" ##TODO:   

$authHeader = @{
  'Content-Type'='application/json'
  'Authorization'='Bearer ' + $AzAccessToken.Token
}


$apiVersion = "2023-01-01";  ## const

$csvfn_RecomendationsByList = "$cvsFilePathTemplate\advRecomendationsByList-$($csvReportDate).csv"; ## compose csv report file name
if ($applyAdvisorFilter) {
  Write-Host "`tApplied filter: $($advisorFilter)" -ForegroundColor Blue
}
else {
  Write-Host "`tThe filter $($advisorFilter) is defined but will not be applied." -ForegroundColor Yellow
  Write-Host "`tSet the parameters `$applyAdvisorFilter = `$true; in the parameters section to apply the filter." -ForegroundColor Yellow
}

$advRecomendationsByList = $null;  ## reset of result variable

## get recomendations  (pass array of subscriptions )
## take result as [array] always to prevent unwarp into object (need if count = 1)
if ($applyAdvisorFilter) {
  [array]$advRecomendationsByList = Get-AzAdvisorRecommendation -SubscriptionId $arrSubscription -Filter $advisorFilter;
}
else {
  [array]$advRecomendationsByList = Get-AzAdvisorRecommendation -SubscriptionId $arrSubscription  
}


if ($advRecomendationsByList.Count -eq 0) {
  Write-Host "No recommendations were found. File of results not created." -ForegroundColor Yellow; 
  Exit; 
}  
else {
  Write-Host "`tCount of recommendations:  $($advRecomendationsByList.Count)" -ForegroundColor Green;
  Write-Host "`tThe result will be save in csv file: $($csvfn_RecomendationsByList)" -ForegroundColor Green;
  $_loopCntr = 1;
  foreach ($item in $advRecomendationsByList) {
    $csvrow_advRecomendationsByList = ConvertTo-Csv -InputObject $item 

    ## get csv Header 
    if ($_loopCntr -eq 1) {   
      $csvrow_advRecomendationsByList[0] | Add-Content -Path $csvfn_RecomendationsByList
    }
    $csvrow_advRecomendationsByList[1] | Add-Content -Path $csvfn_RecomendationsByList;

    $htSubscriptionAdvisorRecomendations.Add($_loopCntr,$item)  ## put recomendation into hastable as well
    $_loopCntr++;  
  };
}
Write-Host "---";



