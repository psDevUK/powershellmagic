---
branding:
  title: "Powershell Blog"
authors:
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-09-22
icon: heart
label: Convert-Image2Text
order: 86
---

# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

![If only Microsoft did toy figures how cool would that be|400](/images/ToyHero.png)

## Puppy update

Been a few blogs since I mentioned the puppies. So 3 have been sold, but I still need to find forever homes for 3 more boy puppies. I think it is crazy that they have not sold already as they really are adorable looking full breed Shar Pei puppies. I mean my wife and I dropped the price a bit too, as I do not think it is realistic to have 7 dogs (my wife would probably disagree) I apprecite buying a dog is not super cheap, but like one person said they were thinking of 500, so my wife politely replied letting them know the eye tacking alone was 400, then plus 92 for vacinations and micro-chipping. So 'we' would be looking at 8 quid profit.  Not including all the food and puppy milk I have paid out for.  So yeah did say to that person that this is why they are listed for 850. Which was a drop from 1000, but I see people selling mongrels on their like shar-doodle or something crazy for like 1,500 which to me is taking the biscuit. The pups I have for sale are pure Shar-Pei dogs but I know the cost of living is mental as well at the moment. As my wife has had a few people asking if we take payment plans. I am already bank of dad to my 5 daughters, I am not a bank for the general public, and then it's like well if you don't have the cash fully to pay for a pup, do you have the money to feed the pup? And pay for vet bills if required. Maybe I love my dogs to much to let them go to just any-body as I genuinely want them to go to good homes. Just like this family I may know who never walk their dog, they may have initially enquired about the puppies, but like even if they offered double or treble the selling price it would be a no-go as I don't want these pups to be imprisoned in a house all day. That to me is no life for a dog to be stuck in the house everyday all day. Personally I think it would be great if dogs got more rights, as in if you are a dog owner you need to walk your dog, end of, it should be illegal to own a dog and never walk it in my opinion. 
![One of the boy pups still for sale|400](/images/cooper.PNG)
Enough babbling on about dog rights, and puppies for sale, let's get moving on shall we...

## Ascii Art

So I was thinking before I done this blog, lets use one of the many modules I have published to the PowerShell gallery to add some more bling factor to my blog site. Like more cool images exclusive to this site only:

![A superhero idea I had|400](/images/MrEng.PNG)

Then turning this image into text to display right in your PowerShell 7 console directly like this:

![Image in Ascii Art with colour how epic is this now in text format in colour in my PowerShell console window|400](/images/Eman.PNG)

In this blog we are going to cover using PowerShell for all your ascii art needs and desires. 

## Binary Modules

To me not enough talk is done on PowerShell binary modules, like you see people blogging about advanced functions, to then publish as modules, or a while back when Microsoft released Crescendo Modules coverting an older based .exe into pure PowerShell object orientated output. But very little is talked about Binary modules, and what they are and how to create them. So we can cover all that in this blog. Which I know will be a tantalizing read, so lets make that happen on Monday night. 

!!!
A PowerShell binary module is an assembly (.dll) that contains cmdlet classes. These modules can be created using C# and provide significant performance benefits, especially for tasks that involve complex operations like JSON processing or working with hashtables.
!!!

So I did make a binary module which did this a while ago, which I documented here on my old blog-site:
https://adam-bacon.netlify.app/binary-modules/image2text/

However if like me you don't do something for years it can be quite hard to remember exactly how you done it. As the reason I went for a complete re-make of this module is because when I wrote this module years ago, I was running a very old x86 Windows 7 laptop. It worked great and I was so happy I did the blog on it.  However I still need to make all my modules update more frequently, as when I went to use this module I had create now running on an x64 Windows 10 laptop the module did not work. 

So I wanted to make it more resilient this time round, so it would work on x64 systems, and use the latest PowerShell 7+ but I would need some assistance on this. So I called my super-handy AI assistant I created and shared in my previous blog. Although I did not get the full answer in one reply, after we discussed this project and how to pull it off I got the answers I needed.

## Follow along and make a binary module with me

So first off just like building a house we need to have some sort of structure. That structure which I am talking about is the directory structure, that 'we' will create to host this module in. 

{.list-icon}
- :icon-file-directory: Main Directory - Image2Text
    - :icon-code-square: Image2Text.csproj
    - :icon-code-square: TextImage.cs
    - :icon-code-square: Image2Text.psd1
    - :icon-code-square: Image2Text.psm1

Once I opened this main folder up in VS code, I then needed to create the files listed above within this directory. 

To start off lets show the code I needed for the .csproj file which is an XML-based file used by C# projects in Visual Studio and other .NET development environments. It contains essential information and settings that define how the project is built and managed.

**Image2Text.csproj** code shown below
```cs #
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net6.0-windows</TargetFramework>
    <OutputType>Library</OutputType>
    <AssemblyName>Image2Text</AssemblyName>
    <RootNamespace>Image2Text</RootNamespace>
    <PlatformTarget>x64</PlatformTarget>
    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <NoWarn>CA1416</NoWarn> <!-- Suppress Windows-only API warnings -->
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="System.Drawing.Common" Version="7.0.0" />
  </ItemGroup>

</Project>
```

Next I needed to create the **TextImage.cs**  this **.cs** file is a source code file written in the C# programming language, which was developed by Microsoft. These files are primarily used in the .NET Framework or .NET Core environments to create a wide range of applications, including desktop software, web applications, and games.
The .cs file format is text-based and contains human-readable instructions that are compiled into executable files (e.g., .exe or .dll).  We want this in a **.dll** but first we need to code it

**TextImage.cs** code below
```cs #
using System;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace Image2Text
{
    public class AsciiConverter
    {
        // High-density character set ordered darkest to lightest
        private static readonly string Charset = "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,\"^`'. ";

        /// <summary>
        /// Converts an image to ASCII art, optionally with ANSI color.
        /// </summary>
        public static string[] Convert(string imagePath, int width, double aspectRatio, double gamma, bool useColor)
        {
            if (!System.IO.File.Exists(imagePath))
                throw new ArgumentException("Image not found: " + imagePath);

            using (var original = new Bitmap(imagePath))
            {
                int height = (int)Math.Round(original.Height * ((double)width / original.Width) * aspectRatio);

                // High-quality resize
                Bitmap resized = new Bitmap(width, height);
                using (Graphics g = Graphics.FromImage(resized))
                {
                    g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    g.SmoothingMode = SmoothingMode.HighQuality;
                    g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                    g.CompositingQuality = CompositingQuality.HighQuality;
                    g.DrawImage(original, 0, 0, width, height);
                }

                string[] lines = new string[height];

                for (int y = 0; y < height; y++)
                {
                    string line = "";
                    for (int x = 0; x < width; x++)
                    {
                        Color pixel = resized.GetPixel(x, y);
                        double luminance = 0.2126 * pixel.R + 0.7152 * pixel.G + 0.0722 * pixel.B;
                        double normalized = Math.Pow(luminance / 255.0, 1.0 / gamma);
                        int index = (int)(normalized * (Charset.Length - 1));
                        char asciiChar = Charset[index];

                        if (useColor)
                        {
                            string ansi = $"\u001b[38;2;{pixel.R};{pixel.G};{pixel.B}m";
                            line += ansi + asciiChar;
                        }
                        else
                        {
                            line += asciiChar;
                        }
                    }

                    // Reset color at end of line
                    lines[y] = useColor ? line + "\u001b[0m" : line;
                }

                resized.Dispose();
                return lines;
            }
        }
    }
}
```
With these two code files created we can now generate the dll file we need, but to get that to work, we need to edit the psd1 and psm1 files to load in this newly created dll. So here is the PowerShell code to do that.

Here is the main **psd1** file code to have the module defined should we wish to publish this. 
```ps1 #
@{
    # Module metadata
    RootModule         = 'Image2Text.psm1'
    ModuleVersion      = '1.0.4'
    GUID               = 'd3f9c5a2-7f3e-4c2f-9a1e-abc123456789'
    Author             = 'Adam B.'
    CompanyName        = 'PowerShellMagic'
    Description        = 'Converts images to ASCII art with optional color output and file export. Built for creative automation and terminal flair.'

    # Compatible with PowerShell 5.1 and 7+
    PowerShellVersion  = '7.0'
    CompatiblePSEditions = @('Desktop', 'Core')

    # Functions to export
    FunctionsToExport  = @('Convert-Image2Text')

    # Cmdlets, aliases, variables
    CmdletsToExport    = @()
    AliasesToExport    = @()
    VariablesToExport  = @()

    # Required assemblies
    RequiredAssemblies = @('Image2Text.dll')

    # Private data (optional)
    PrivateData = @{
        PSData = @{
            Tags         = @('ASCII', 'Image', 'Color', 'Terminal', 'Art', 'Export')
            LicenseUri   = 'https://opensource.org/licenses/MIT'
            ProjectUri   = 'https://github.com/yourrepo/Image2Text'
            IconUri      = 'https://yourdomain.com/icon.png'
            ReleaseNotes = 'Added support for color output, file saving, and plain text export.'
        }
    }
}
```

Then finally need to write the function to do the magic by communicating and loading the assembly file we are about to generate

**PSM1** code below

```ps1 #
<#
.SYNOPSIS
Converts images to ASCII art with optional color rendering and file export.

.DESCRIPTION
This module provides a high-performance wrapper around a .NET-based image-to-text converter. It transforms raster images into terminal-friendly ASCII representations, with support for:

- True-color ANSI output for rich console rendering
- Aspect ratio correction and gamma tuning
- File export with automatic plain-text formatting
- Parameter sets to enforce safe and predictable usage

Designed for PowerShell 6 and 7+, it supports creative automation, terminal art, and comic-style branding workflows.

.PARAMETER ImagePath
Path to the input image file (e.g., PNG, JPG, BMP).

.PARAMETER Width
Target width in characters for the ASCII output. Height is auto-calculated based on image dimensions and aspect ratio.

.PARAMETER AspectRatio
Aspect ratio correction factor to compensate for character height distortion in terminal fonts. Default is 0.55.

.PARAMETER Gamma
Gamma correction factor to adjust perceived brightness. Default is 2.2.

.PARAMETER UseColor
Switch to enable true-color ANSI output for console rendering. Only available in the 'Console' parameter set.

.PARAMETER SaveToFile
Path to save the ASCII output as a plain-text file. Automatically strips ANSI codes. Only available in the 'File' parameter set.

.PARAMETER InvertColor
Switch to invert image colors before conversion. Only available in the 'File' parameter set. This uses MS Paint to perform the inversion.

.EXAMPLE
Convert-Image2Text -ImagePath "C:\Images\logo.png" -Width 150 -UseColor

.EXAMPLE
Convert-Image2Text -ImagePath "C:\Images\logo.png" -Width 150 -SaveToFile "C:\Output\logo.txt"

.EXAMPLE
Convert-Image2Text -ImagePath "C:\Images\logo.png" -Width 400 -SaveToFile "C:\Output\logo.txt" -InvertColor

.NOTES
Author: Adam B.
Module: Image2Text
Version: 1.0.0
License: MIT
#>

# Load the compiled .NET assembly vital to this module's functionality
$assemblyPath = Join-Path $PSScriptRoot 'Image2Text.dll'
if (-not (Test-Path $assemblyPath)) {
    throw "Required assembly not found: $assemblyPath"
}
Add-Type -Path $assemblyPath

function Convert-Image2Text {
    [CmdletBinding(DefaultParameterSetName = 'Console')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Console')]
        [Parameter(Mandatory, ParameterSetName = 'File')]
        [string]$ImagePath,

        [Parameter(ParameterSetName = 'Console')]
        [Parameter(ParameterSetName = 'File')]
        [int]$Width = 100,

        [Parameter(ParameterSetName = 'Console')]
        [Parameter(ParameterSetName = 'File')]
        [double]$AspectRatio = 0.55,

        [Parameter(ParameterSetName = 'Console')]
        [Parameter(ParameterSetName = 'File')]
        [double]$Gamma = 2.2,

        [Parameter(ParameterSetName = 'Console')]
        [switch]$UseColor,

        [Parameter(Mandatory, ParameterSetName = 'File')]
        [string]$SaveToFile,

        [Parameter(ParameterSetName = 'File')]
        [switch]$InvertColor

    )

    try {
        if (-not (Test-Path $ImagePath)) {
            throw "Image file not found: '$ImagePath'"
        }

        $useColorFlag = $UseColor.IsPresent
        $lines = [Image2Text.AsciiConverter]::Convert($ImagePath, $Width, $AspectRatio, $Gamma, $useColorFlag)

        if ($PSCmdlet.ParameterSetName -eq 'File') {
            if ($PSCmdlet.ParameterSetName -eq 'File') {
                # Always strip ANSI codes for file output
                $lines = $lines | ForEach-Object { $_ -replace "\u001b\[[0-9;]*m", "" }
            }

            $parentFolder = Split-Path $SaveToFile -Parent
            if (-not (Test-Path $parentFolder)) {
                throw "SaveToFile path is invalid or the folder does not exist: '$parentFolder'"
            }

            if ($InvertColor.IsPresent) {
                $tempPath = Join-Path $env:TEMP ("inverted_" + [System.IO.Path]::GetFileName($ImagePath))
                Copy-Item $ImagePath $tempPath -Force
                Write-Host "Inverting image colors via MS Paint..."

                # Launch Paint
                Start-Process "mspaint.exe" -ArgumentList "`"$tempPath`""
                Start-Sleep -Seconds 2  # Give Paint time to open

                # Create VBScript to send keys
                $vbs = @"
Set WshShell = WScript.CreateObject("WScript.Shell")
WScript.Sleep 1000
WshShell.SendKeys "^a"
WScript.Sleep 500
WshShell.SendKeys "^+i"
WScript.Sleep 500
WshShell.SendKeys "^s"
WScript.Sleep 500
WshShell.SendKeys "%{F4}"
"@

                $vbsPath = Join-Path $env:TEMP "invertPaint.vbs"
                Set-Content -Path $vbsPath -Value $vbs -Encoding ASCII

                # Run the VBScript
                Start-Process "wscript.exe" -ArgumentList "`"$vbsPath`"" -WindowStyle Hidden

                Start-Sleep -Seconds 3  # Wait for Paint to close and save

                # Use the inverted image
                $ImagePath = $tempPath
            }



            try {
                [System.IO.File]::WriteAllLines($SaveToFile, $lines)
                Write-Host "ASCII output saved to: $SaveToFile"
            } catch {
                throw "Failed to write to file: '$SaveToFile'. Check permissions."
            }
        } else {
            $lines
        }
    } catch {
        Write-Error $_
    }
}
```

So now you got those four files all prepped and ready in VS Code, you next need to run this code to build the magic .dll file from the csproj and cs file. 

Code to build the .dll file required to make this awesomeness happen
```
dotnet build -c Release
```

Boom you should see an extra couple of folders now appear in your project directory, and I copied the .dll file which was produced in **bin\Release\net6.0-windows** directly into the main directory with the other 4 files we just created. As this should make loading it easier, and well just get everything to work as I envisioned. I also learnt a new way of inspecting the dll file as originally I did not have all the parameters like **-UseColor** or **-SaveToFile** in the original dll and wanted to add those in, so to check the available parameters on the dll file I ran:

```ps1 #
[Image2Text.AsciiConverter].GetMethod("Convert").GetParameters()
```

To verify that all the options I wanted for this existed in the dll file itself. All this typing is making me hungry, so I am going to go eat my dinner now, and hopefully you had a blast reading this blog and learning about something new. Thanks for reading.