Write-Output "[ ] Attempting to set Commando VM wallpaper"

$path = $args[0]
$setwallpapersrc = @"
using System.Runtime.InteropServices;

public class Wallpaper
{
  public const int SetDesktopWallpaper = 20;
  public const int UpdateIniFile = 0x01;
  public const int SendWinIniChange = 0x02;
  [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
  private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
  public static void SetWallpaper(string path)
  {
    SystemParametersInfo(SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange);
  }
}
"@

Add-Type -TypeDefinition $setwallpapersrc

$sourceImage = "https://raw.githubusercontent.com/mandiant/commando-vm/main/Images/background.png"
$destinationImage = "C:\background.png"

try {
  Invoke-WebRequest $sourceImage -OutFile $destinationImage
  [Wallpaper]::SetWallpaper("C:\background.png")
  Write-Output "[*] Successfully set Commando VM wallpaper"
} catch {
  Write-Error "[*] Failed to set Commando VM wallpaper" -ErrorAction Stop
}
