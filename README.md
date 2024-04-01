<p align="center">
	<img src="./brand/logo_wide_dark.png" alt="AssetFetch Logo" width="400"/>
</p>

# The AssetFetch Specification

**AssetFetch** is an HTTP- and JSON-based system for browsing, retrieving and handling/importing digital assets for media creation.
The AssetFetch Protocol aims to provide a standardized way for artists to browse libraries of downloadable assets offered by providers *outside* their current production environment/pipeline, such as those of commercial or non-profit 3D asset vendors, marketplaces or other repositories of models, textures or any other kind of digital assets.

It aims to help in creating an artist experience similar to existing native integrations, such as proprietary import plugins like, with less development overhead in order to increase interoperability between vendors and applications and allow more vendors - especially smaller ones - to offer their assets to artists right in the applications where they need them.

Currently, a draft of version 0.2 is available and can be read in [spec.md](./spec.md).

# Features

- Header-based Authentication using numerous methods and a login-system to show account balance
- Browsing assets with thumbnails, server-side searching and filtering, license data, author data and more
- Support for multiple resolutions, quality levels or any other kind of variation of assets
- Support for zipped downloads: Providers can still send metadata for individual asset files, even if the actual download arrives in just one zip file.
- Ways for checking compatibility with different open or vendor-native formats: The provider offers metadata for multiple versions of the same asset which the client can use to judge whether it will be able to actually import the file BEFORE downloading it, as best as possible (100% certainty will be impossible).
- Support for dynamically generated asset downloads (think ticking boxes about which PBR maps you want and then getting a Zip file with exactly those maps)
- Purchasing assets (even composite assets that require multiple purchases) through an "asset unlocking" system. (The actual payment isn't handled by AF, users still need to sign up on the provider's website)
- Support for temporarily generated download links
- Ways of linking loose files together to cover "loose materials" (i.e. materials that arrive as just a bunch of material maps without any further files like .MTLX)
- Theming and branding options for providers with banner images, if the client chooses to display those.
- Custom metadata for common file formats, like which axis represents "up" in an .obj file.

# This is a Work-In-Progress
Everything here at the moment should be regarded as a starting-off point for future testing and discussion about how the transfer of 3D assets from vendors to clients can be made made more open and interoperable.

There are still numerous milestones to hit before a version 1.0 can be released. Among other things...

- Create better examples for basically everything. This includes examples for every element of the specification as well as more general examples and user stories to better illustrate what AssetFetch is, how it works and the value it delivers both for asset vendors and users.

- Create proof-of-concept implementations both for the provider- and the client-side in order to demonstrate the viability of the entire system. This will also inevitably lead to changes and clarifications in the spec as problems are encountered and (hopefully) solved.

- Create more extension-specific datablock definitions for many more formats, both open and application-specific ones (`max`(3DSMax),`ma/mb`(Maya),`uasset`(Unreal Engine),`usda/c/z` (OpenUSD), `gltf/b`(GLTF),...) 

- Create JSON schema documents for every endpoint and datablock to help with validation.

- ...

# JSON Schema

JSON-Schemas for AssetFetch are provided in the `/json-schema` subdirectory of this repository.

# Contributing
Currently the best way to contribute is by opening issues with questions, contradictions in the specifications, suggestions for datablocks or any other thoughts about the specification.