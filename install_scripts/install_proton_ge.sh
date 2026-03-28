# Make a temporary working directory
echo "Creating a temporary working directory..."
rm -rf /tmp/proton-ge-custom
mkdir /tmp/proton-ge-custom
cd /tmp/proton-ge-custom

# Download the tarball for the latest release
echo "Fetching tarball URL..."
tarball_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)
tarball_name=$(basename $tarball_url)
echo "Downloading tarball: $tarball_name..."
curl -# -L $tarball_url -o $tarball_name --no-progress-meter

# Download the checksum for the latest release 
echo "Fetching checksum URL..."
checksum_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)
checksum_name=$(basename $checksum_url)
echo "Downloading checksum: $checksum_name..."
curl -# -L $checksum_url -o $checksum_name --no-progress-meter

# Verify the downloaded tarball with the downloaded checksum
echo "Verifying tarball $tarball_name with checksum $checksum_name..."
sha512sum -c $checksum_name
# If result the verification succeeds, continue

# Make a Steam compatibility tools folder if it does not exist
echo "Creating a Steam directory if it does not exist..."
mkdir -p ~/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d

# Extract the GE-Proton tarball to the Steam compatibility tools folder
echo "Extracting $tarball_name to the Steam compatibility tools folder..."
tar -xf $tarball_name -C ~/.steam/root/compatibilitytools.d/
echo "All done :)"
