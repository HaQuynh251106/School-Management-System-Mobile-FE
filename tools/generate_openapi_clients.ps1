param(
  [string]$BackendRoot = "",
  [string]$GeneratorVersion = "7.24.0",
  [string]$DartExecutable = ""
)

$ErrorActionPreference = "Stop"

$mobileRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrWhiteSpace($BackendRoot)) {
  $BackendRoot = Join-Path (Split-Path $mobileRoot -Parent) "School-Management-System-BE"
}
$backendRootPath = (Resolve-Path $BackendRoot).Path
if ([string]::IsNullOrWhiteSpace($DartExecutable)) {
  $dartCommand = Get-Command dart -ErrorAction SilentlyContinue
  if ($null -ne $dartCommand) {
    $DartExecutable = $dartCommand.Source
  } elseif (-not [string]::IsNullOrWhiteSpace($env:FLUTTER_ROOT)) {
    $DartExecutable = Join-Path $env:FLUTTER_ROOT "bin\dart.bat"
  } else {
    $driveFlutter = Join-Path (Split-Path $mobileRoot -Qualifier) "flutter\bin\dart.bat"
    if (Test-Path -LiteralPath $driveFlutter) {
      $DartExecutable = $driveFlutter
    }
  }
}
if (-not (Test-Path -LiteralPath $DartExecutable)) {
  throw "Khong tim thay Dart. Hay them dart vao PATH hoac truyen -DartExecutable."
}

$cacheDir = Join-Path $HOME ".cache\openapi-generator\$GeneratorVersion"
$jarPath = Join-Path $cacheDir "openapi-generator-cli.jar"
if (-not (Test-Path -LiteralPath $jarPath)) {
  New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null
  $jarUrl = "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/$GeneratorVersion/openapi-generator-cli-$GeneratorVersion.jar"
  Write-Host "Downloading OpenAPI Generator $GeneratorVersion..."
  Invoke-WebRequest -Uri $jarUrl -OutFile $jarPath
}

$clients = @(
  @{ Contract = "finance"; Package = "sse_finance_api" },
  @{ Contract = "identity"; Package = "sse_identity_api" },
  @{ Contract = "academic"; Package = "sse_academic_api" },
  @{ Contract = "report"; Package = "sse_report_api" }
)

foreach ($client in $clients) {
  $contract = $client.Contract
  $package = $client.Package
  $specPath = Join-Path $backendRootPath "docs\openapi\$contract.yaml"
  if (-not (Test-Path -LiteralPath $specPath)) {
    throw "Khong tim thay OpenAPI $contract tai: $specPath"
  }

  $outputPath = Join-Path $mobileRoot "packages\$package"
  $outputParent = Split-Path $outputPath -Parent
  New-Item -ItemType Directory -Force -Path $outputParent | Out-Null
  $resolvedParent = (Resolve-Path $outputParent).Path
  if (-not $resolvedParent.StartsWith($mobileRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Thu muc sinh ma nam ngoai Mobile repository: $resolvedParent"
  }
  if (Test-Path -LiteralPath $outputPath) {
    Remove-Item -LiteralPath $outputPath -Recurse -Force
  }

  & java -jar $jarPath generate `
    -g dart-dio `
    -i $specPath `
    -o $outputPath `
    --additional-properties "pubName=$package,pubVersion=0.1.0,serializationLibrary=json_serializable"
  if ($LASTEXITCODE -ne 0) {
    throw "OpenAPI Generator ket thuc voi ma loi $LASTEXITCODE cho $contract"
  }

  $generatedPubspec = Join-Path $outputPath "pubspec.yaml"
  $pubspecContent = Get-Content -LiteralPath $generatedPubspec -Raw
  $expectedSdk = "sdk: '>=3.5.0 <4.0.0'"
  if (-not $pubspecContent.Contains($expectedSdk)) {
    throw "Khong tim thay SDK constraint mong doi trong generated pubspec $package"
  }
  $pubspecContent = $pubspecContent.Replace($expectedSdk, "sdk: '>=3.8.0 <4.0.0'")
  Set-Content -LiteralPath $generatedPubspec -Value $pubspecContent -Encoding utf8

  if ($contract -eq "finance") {
    $payRequestPath = Join-Path $outputPath "lib\src\model\pay_request.dart"
    $payRequestContent = Get-Content -LiteralPath $payRequestPath -Raw
    $brokenEnumDefault = "const PayRequestMethodEnum._('VIETQR')"
    if (-not $payRequestContent.Contains($brokenEnumDefault)) {
      throw "Khong tim thay enum default mong doi trong PayRequest"
    }
    $payRequestContent = $payRequestContent.Replace($brokenEnumDefault, "PayRequestMethodEnum.VIETQR")
    $payRequestContent = $payRequestContent -replace "(?m)^\s*defaultValue: 'VIETQR',\r?\n", ""
    Set-Content -LiteralPath $payRequestPath -Value $payRequestContent -Encoding utf8

    $financeApiPath = Join-Path $outputPath "lib\src\api\finance_payments_api.dart"
    $financeApiContent = Get-Content -LiteralPath $financeApiPath -Raw
    $financeApiContent = $financeApiContent -replace `
      "(?m)^import 'package:sse_finance_api/src/model/api_error\.dart';\r?\n", `
      ""
    Set-Content -LiteralPath $financeApiPath -Value $financeApiContent -Encoding utf8
  }

  if ($contract -eq "identity") {
    $identityApiPath = Join-Path $outputPath "lib\src\api\identity_api.dart"
    $identityApiContent = Get-Content -LiteralPath $identityApiPath -Raw
    $identityApiContent = $identityApiContent -replace `
      "(?m)^import 'package:sse_identity_api/src/model/api_error\.dart';\r?\n", `
      ""
    Set-Content -LiteralPath $identityApiPath -Value $identityApiContent -Encoding utf8
  }

  if ($contract -in @("academic", "report")) {
    $apiName = if ($contract -eq "academic") { "academic_api.dart" } else { "report_api.dart" }
    $apiPath = Join-Path $outputPath "lib\src\api\$apiName"
    $apiContent = Get-Content -LiteralPath $apiPath -Raw
    $apiContent = $apiContent -replace `
      "(?m)^import 'package:$package/src/model/api_error\.dart';\r?\n", `
      ""
    Set-Content -LiteralPath $apiPath -Value $apiContent -Encoding utf8
  }

  Push-Location $outputPath
  try {
    & $DartExecutable pub get
    if ($LASTEXITCODE -ne 0) { throw "dart pub get that bai cho $package" }
    & $DartExecutable run build_runner build --delete-conflicting-outputs
    if ($LASTEXITCODE -ne 0) { throw "build_runner that bai cho $package" }
    & $DartExecutable format lib
    if ($LASTEXITCODE -ne 0) { throw "dart format that bai cho $package" }
  } finally {
    Pop-Location
  }

  Write-Host "Generated $contract client at $outputPath"
}
