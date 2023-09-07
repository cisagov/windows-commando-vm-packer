Write-Output "[ ] Attempting to set Commando VM wallpaper"

$sourceImage = "https://raw.githubusercontent.com/mandiant/commando-vm/main/Images/background.png"
$destinationImage = "C:\background.png"

# Utilize user32.dll module which allows the manipulation
# of standard elements of the Windows user interface
$setWallpaperSrc = @'
using System.Runtime.InteropServices;
namespace Win32{

     public class Wallpaper{
        [DllImport("user32.dll", CharSet=CharSet.Auto)]
         static extern int SystemParametersInfo (int uAction , int uParam , string lpvParam , int fuWinIni) ;

         public static void SetWallpaper(string thePath){
            SystemParametersInfo(20,0,thePath,3);
         }
    }
 }
'@

Add-Type $setWallpaperSrc
try {
  Invoke-WebRequest $sourceImage -OutFile $destinationImage
  [Win32.Wallpaper]::SetWallpaper($destinationImage)
  Write-Output "[*] Successfully set Commando VM wallpaper"
} catch {
  Write-Error "[*] Failed to set Commando VM wallpaper" -ErrorAction Stop
}
