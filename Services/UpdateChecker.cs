using System;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using DemoDeploy.Models;

namespace DemoDeploy.Services
{
    /// <summary>
    /// Service to check for application updates
    /// Supports checking from AppInstaller file or custom API
    /// </summary>
    public class UpdateChecker
    {
        private readonly HttpClient _httpClient;
        private const string UPDATE_CHECK_URL = "https://raw.githubusercontent.com/Luongsosad/Deploy-WinUI/main/Deployment/update.json";

        public UpdateChecker()
        {
            _httpClient = new HttpClient();
            _httpClient.Timeout = TimeSpan.FromSeconds(10);
        }

        /// <summary>
        /// Check for updates from remote server
        /// </summary>
        public async Task<VersionInfo> CheckForUpdatesAsync()
        {
            var versionInfo = new VersionInfo
            {
                CurrentVersion = VersionHelper.GetAppVersion()
            };

            try
            {
                // Try to fetch update information from remote JSON
                var response = await _httpClient.GetStringAsync(UPDATE_CHECK_URL);
                var updateData = JsonSerializer.Deserialize<UpdateData>(response);

                if (updateData != null)
                {
                    versionInfo.LatestVersion = Version.Parse(updateData.Version);
                    versionInfo.ReleaseNotes = updateData.ReleaseNotes;
                    versionInfo.DownloadUrl = updateData.DownloadUrl;
                    versionInfo.ReleaseDate = DateTime.Parse(updateData.ReleaseDate);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Update check failed: {ex.Message}");
                // Use mock data for demo if update check fails
                versionInfo.LatestVersion = new Version(1, 0, 2, 0);
                versionInfo.ReleaseNotes = "Demo: New features and bug fixes\n• Feature 1: Enhanced UI\n• Feature 2: Performance improvements\n• Bug fixes";
                versionInfo.DownloadUrl = "https://github.com/yourusername/demodeploy/releases/latest";
                versionInfo.ReleaseDate = DateTime.Now;
            }

            return versionInfo;
        }

        /// <summary>
        /// Check for updates using Windows AppInstaller API
        /// Requires app to be deployed with AppInstaller file
        /// </summary>
        public async Task<bool> CheckAndInstallUpdateAsync()
        {
            try
            {
                // Check if running as packaged app
                if (!Windows.ApplicationModel.Package.Current.SignatureKind.Equals(
                    Windows.ApplicationModel.PackageSignatureKind.None))
                {
                    // Use Windows.Services.Store for checking updates
                    var context = Windows.Services.Store.StoreContext.GetDefault();
                    var updates = await context.GetAppAndOptionalStorePackageUpdatesAsync();

                    if (updates != null && updates.Count > 0)
                    {
                        // Trigger update download and install
                        var downloadOperation = context.RequestDownloadAndInstallStorePackageUpdatesAsync(updates);
                        var result = await downloadOperation.AsTask();
                        
                        return result.OverallState == Windows.Services.Store.StorePackageUpdateState.Completed;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Auto-update failed: {ex.Message}");
            }

            return false;
        }

        /// <summary>
        /// Mock data for demo purposes
        /// </summary>
        public VersionInfo GetMockUpdateInfo()
        {
            return new VersionInfo
            {
                CurrentVersion = VersionHelper.GetAppVersion(),
                LatestVersion = new Version(1, 0, 2, 0),
                ReleaseNotes = "📦 Version 1.0.2 Available!\n\n✨ New Features:\n• Modern deployment system\n• Auto-update functionality\n• Version tracking\n• MSIX packaging\n\n🐛 Bug Fixes:\n• Performance improvements\n• UI enhancements\n\n📅 Release Date: " + DateTime.Now.ToString("dd/MM/yyyy"),
                DownloadUrl = "https://github.com/yourusername/demodeploy/releases/latest",
                ReleaseDate = DateTime.Now
            };
        }

        private class UpdateData
        {
            public string Version { get; set; } = "1.0.0.0";
            public string ReleaseNotes { get; set; } = "";
            public string DownloadUrl { get; set; } = "";
            public string ReleaseDate { get; set; } = "";
        }
    }
}
