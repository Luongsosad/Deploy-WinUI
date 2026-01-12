using System;

namespace DemoDeploy.Models
{
    /// <summary>
    /// Model for version information
    /// </summary>
    public class VersionInfo
    {
        public Version CurrentVersion { get; set; } = new Version(1, 0, 1, 0);
        public Version LatestVersion { get; set; } = new Version(1, 0, 1, 0);
        public string ReleaseNotes { get; set; } = string.Empty;
        public string DownloadUrl { get; set; } = string.Empty;
        public DateTime ReleaseDate { get; set; }
        public bool IsUpdateAvailable => LatestVersion > CurrentVersion;
        public string CurrentVersionString => CurrentVersion.ToString();
        public string LatestVersionString => LatestVersion.ToString();
    }
}
