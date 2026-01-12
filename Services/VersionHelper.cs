using System;
using System.Reflection;
using Windows.ApplicationModel;

namespace DemoDeploy.Services
{
    /// <summary>
    /// Helper class to get application version information
    /// </summary>
    public static class VersionHelper
    {
        /// <summary>
        /// Get current app version from Package
        /// </summary>
        public static Version GetAppVersion()
        {
            try
            {
                var package = Package.Current;
                var version = package.Id.Version;
                return new Version(version.Major, version.Minor, version.Build, version.Revision);
            }
            catch
            {
                // Fallback to assembly version if not packaged
                return Assembly.GetExecutingAssembly().GetName().Version ?? new Version(1, 0, 0, 0);
            }
        }

        /// <summary>
        /// Get app package ID name
        /// </summary>
        public static string GetPackageId()
        {
            try
            {
                return Package.Current.Id.Name;
            }
            catch
            {
                return "DemoDeploy";
            }
        }

        /// <summary>
        /// Get publisher name
        /// </summary>
        public static string GetPublisher()
        {
            try
            {
                return Package.Current.PublisherDisplayName;
            }
            catch
            {
                return "LUONG";
            }
        }

        /// <summary>
        /// Get app display name
        /// </summary>
        public static string GetDisplayName()
        {
            try
            {
                return Package.Current.DisplayName;
            }
            catch
            {
                return "DemoDeploy";
            }
        }
    }
}
