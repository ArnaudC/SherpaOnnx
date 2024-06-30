# Usage: .\start.ps1
# Requires : Dotnet, 'dotnet tool install --global dotnet-ef'
# Execute SetRemoteSignedPolicy the first time to grant execution policy to this script
param(
  [String] $Command,
  [Parameter(Mandatory=$false)][String] $Arg1
)

function HelpMessage() {
    echo "Usage : ./start.ps1 <command>"
    echo " tts 'a text to speak'            Run TTS"
}

function Tts {
    $outputFileName = "output.wav"
    $cmd = "./$env:SHERPA_ONNX_PATH/bin/sherpa-onnx-offline-tts.exe --vits-model=./$env:VITS_LJS_PATH/vits-ljs.onnx --vits-lexicon=./$env:VITS_LJS_PATH/lexicon.txt --vits-tokens=./$env:VITS_LJS_PATH/tokens.txt --output-filename=./output/$outputFileName '$Arg1'"
    echo $cmd
    iex $cmd
    (New-Object Media.SoundPlayer "./output/$outputFileName").Play() # Read wav output file
}

function CdCurrentDirectory {
    cd $CurrentDir
}

function Main {
    try {
        Set-PSDebug -Trace 1
        # .env
        if (!(Test-Path "$CurrentDir\.env")) {
            Copy-Item "$CurrentDir\.env.tpl" "$CurrentDir\.env"
        }
        get-content .env | foreach {
            $name, $value = $_.split('=')
            set-content env:\$name $value
        }

        # Command to function
        if ($Command -eq "tts") {
            Tts
        } else {
            Set-PSDebug -Trace 0
            echo "Command '$Command' not found."
            HelpMessage
        }
    }
    catch {
        Write-Warning "$_"
    }
    finally {
        CdCurrentDirectory # Back to current directory
        Set-PSDebug -Trace 0
    }
}

Set-PSDebug -Trace 0
$CurrentDir=$PSScriptRoot # Get current directory
Main
