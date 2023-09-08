Write-Output "[ ] Attempting to set Commando VM wallpaper"

$sourceImage = "https://raw.githubusercontent.com/mandiant/commando-vm/main/Images/background.png"
$destinationImage = "C:\background.png"

# Utilize user32.dll module which allows the manipulation
# of standard elements of the Windows user interface
#
# SystemParametersInfo params:
#
# uAction  - set to 20, which is an identifier for setting the desktop wallpaper.
#
# The following parameters' purpose depends on the uAction parameter being set:
#
# uParam   - Must be set to 0 when setting the desktop wallpaper.
# lpvParam - Used to set the image path when setting the desktop wallpaper.
# fuWinIni - Set to 3 to indicate that the user profile is to be updated.
#
# For more information, see: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfoa
$setWallpaperSrc = @'
using System.Runtime.InteropServices;
namespace Win32{

     public class Wallpaper{
        [DllImport("user32.dll", CharSet=CharSet.Auto)]
         static extern int SystemParametersInfo (int uAction , int uParam , string lpvParam , int fuWinIni) ;

         public static void SetWallpaper(string imagePath){
            SystemParametersInfo(20, 0, imagePath, 3);
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
