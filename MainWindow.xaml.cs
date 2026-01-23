using System;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using DemoDeploy.Services;
using DemoDeploy.Models;

namespace DemoDeploy
{
    public sealed partial class MainWindow : Window
    {
        private readonly UpdateChecker _updateChecker;

        public MainWindow()
        {
            InitializeComponent();
            _updateChecker = new UpdateChecker();
            LoadVersionInfo();
        }

        private void LoadVersionInfo()
        {
            try
            {
                var version = VersionHelper.GetAppVersion();
                var packageId = VersionHelper.GetPackageId();
                var publisher = VersionHelper.GetPublisher();

                VersionText.Text = $"Version: {version}";
                CurrentVersionText.Text = version.ToString();
                PackageIdText.Text = packageId;
                PublisherText.Text = publisher;
                StatusText.Text = "Ready";
            }
            catch (Exception ex)
            {
                StatusText.Text = $"Error loading version: {ex.Message}";
            }
        }

        private async void CheckUpdateButton_Click(object sender, RoutedEventArgs e)
        {
            CheckUpdateButton.IsEnabled = false;
            UpdateProgressBar.Visibility = Visibility.Visible;
            StatusText.Text = "Checking for updates...";

            try
            {
                // Try AppInstaller Store API first (for packaged apps)
                bool storeUpdateSuccess = await _updateChecker.CheckAndInstallUpdateAsync();
                
                if (storeUpdateSuccess)
                {
                    UpdateProgressBar.Visibility = Visibility.Collapsed;
                    StatusText.Text = "Update completed! Restart app to apply.";
                    await ShowInfoDialog(
                        "✅ Update Complete",
                        "The app has been updated successfully. Please restart to use the new version.",
                        "OK");
                    return;
                }
                
                // Fallback to JSON API check (for non-Store deployments)
                var versionInfo = await _updateChecker.CheckForUpdatesAsync();

                UpdateProgressBar.Visibility = Visibility.Collapsed;

                if (versionInfo.IsUpdateAvailable)
                {
                    StatusText.Text = $"Update available: v{versionInfo.LatestVersionString}";
                    await ShowUpdateDialog(versionInfo);
                }
                else
                {
                    StatusText.Text = "You're running the latest version!";
                    await ShowInfoDialog(
                        "No Updates Available",
                        $"You're already running the latest version ({versionInfo.CurrentVersionString}).",
                        "OK");
                }
            }
            catch (Exception ex)
            {
                UpdateProgressBar.Visibility = Visibility.Collapsed;
                StatusText.Text = "Update check failed";
                await ShowInfoDialog("Error", $"Failed to check for updates:\n{ex.Message}", "OK");
            }
            finally
            {
                CheckUpdateButton.IsEnabled = true;
            }
        }

        private async void ViewInfoButton_Click(object sender, RoutedEventArgs e)
        {
            var info = $"?? DemoDeploy - Deployment Information\n\n" +
                       $"Version: {VersionHelper.GetAppVersion()}\n" +
                       $"Package ID: {VersionHelper.GetPackageId()}\n" +
                       $"Publisher: {VersionHelper.GetPublisher()}\n\n" +
                       $"?? Deployment Features:\n" +
                       $"� MSIX Packaging - Modern Windows app packaging\n" +
                       $"� Automatic Versioning - Managed version control\n" +
                       $"� Auto-Update System - Seamless updates\n" +
                       $"� Store Ready - Microsoft Store deployment\n" +
                       $"� Sideloading - Enterprise distribution\n" +
                       $"� AppInstaller - Web-based installation\n\n" +
                       $"??? Technologies:\n" +
                       $"� WinUI 3 (Windows App SDK 1.8)\n" +
                       $"� .NET 8.0\n" +
                       $"� MSIX Packaging\n" +
                       $"� Windows.Services.Store API\n\n" +
                       $"?? Built: {DateTime.Now:dd/MM/yyyy}";

            await ShowInfoDialog("Deployment Information", info, "Close");
        }

        private async System.Threading.Tasks.Task ShowUpdateDialog(VersionInfo versionInfo)
        {
            var dialog = new ContentDialog
            {
                Title = "?? Update Available!",
                Content = new ScrollViewer
                {
                    Content = new StackPanel
                    {
                        Spacing = 12,
                        Children =
                        {
                            new TextBlock
                            {
                                Text = $"A new version is available!",
                                FontWeight = Microsoft.UI.Text.FontWeights.SemiBold
                            },
                            new StackPanel
                            {
                                Spacing = 4,
                                Children =
                                {
                                    new TextBlock { Text = $"Current Version: {versionInfo.CurrentVersionString}" },
                                    new TextBlock 
                                    { 
                                        Text = $"Latest Version: {versionInfo.LatestVersionString}",
                                        Foreground = (Microsoft.UI.Xaml.Media.Brush)Application.Current.Resources["SystemFillColorSuccessBrush"]
                                    }
                                }
                            },
                            new Border
                            {
                                Background = (Microsoft.UI.Xaml.Media.Brush)Application.Current.Resources["CardBackgroundFillColorDefaultBrush"],
                                CornerRadius = new CornerRadius(4),
                                Padding = new Thickness(12),
                                Child = new TextBlock
                                {
                                    Text = versionInfo.ReleaseNotes,
                                    TextWrapping = TextWrapping.Wrap,
                                    FontFamily = new Microsoft.UI.Xaml.Media.FontFamily("Consolas")
                                }
                            },
                            new TextBlock
                            {
                                Text = $"?? Release Date: {versionInfo.ReleaseDate:dd/MM/yyyy}",
                                FontSize = 12,
                                Foreground = (Microsoft.UI.Xaml.Media.Brush)Application.Current.Resources["TextFillColorSecondaryBrush"]
                            }
                        }
                    }
                },
                PrimaryButtonText = "Download Update",
                CloseButtonText = "Later",
                DefaultButton = ContentDialogButton.Primary,
                XamlRoot = this.Content.XamlRoot
            };

            var result = await dialog.ShowAsync();

            if (result == ContentDialogResult.Primary)
            {
                StatusText.Text = "Opening download page...";
                await Windows.System.Launcher.LaunchUriAsync(new Uri(versionInfo.DownloadUrl));
            }
        }

        private async System.Threading.Tasks.Task ShowInfoDialog(string title, string message, string closeButtonText)
        {
            var dialog = new ContentDialog
            {
                Title = title,
                Content = new ScrollViewer
                {
                    MaxHeight = 400,
                    Content = new TextBlock
                    {
                        Text = message,
                        TextWrapping = TextWrapping.Wrap
                    }
                },
                CloseButtonText = closeButtonText,
                XamlRoot = this.Content.XamlRoot
            };

            await dialog.ShowAsync();
        }
    }
}
