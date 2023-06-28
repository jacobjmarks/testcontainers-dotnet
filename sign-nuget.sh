#!/usr/bin/env bash

nuget_dependency="artifacts/3.4.0-beta/nuget/Testcontainers.3.4.0-beta.nupkg"
rm -f "$nuget_dependency"

# country="US"
# state="New Jersey"
# locality="Newark"
# organization="AtomicJar, Inc."
# common_name="My Code Signing Certificate"

# validity_days=365

certificate_file="code_signing.crt"
private_key_file="code_signing.key"

pkcs12_file="code_signing.pfx"
pkcs12_password="gFsL3h401x6T"

# openssl genpkey -algorithm RSA -out "$private_key_file"

# openssl req -new -key "$private_key_file" -out "$certificate_file.csr" -subj "/C=$country/ST=$state/L=$locality/O=$organization/CN=$common_name"

# openssl x509 -req -days "$validity_days" -in "$certificate_file.csr" -signkey "$private_key_file" -out "$certificate_file"

# openssl x509 -in "$certificate_file" -noout -text

# rm "$certificate_file.csr"

# openssl pkcs12 -export -out "$pkcs12_file" -inkey "$private_key_file" -in "$certificate_file" -password "pass:$pkcs12_password"

fingerprint=$(openssl x509 -noout -fingerprint -sha256 -inform pem -in "$certificate_file" | sed "s/sha256 Fingerprint=//" | sed "s/://g")

# Build NuGet
dotnet tool restore

dotnet cake --target=Restore-NuGet-Packages
dotnet cake --target=Build
dotnet cake --target=Create-NuGet-Packages

# Sign NuGet
dotnet nuget sign --certificate-path "$pkcs12_file" --certificate-password "$pkcs12_password" --timestamper "http://ts.quovadisglobal.com/eu" "$nuget_dependency"

# Verify NuGet
dotnet nuget verify "$nuget_dependency" --certificate-fingerprint "$fingerprint"
