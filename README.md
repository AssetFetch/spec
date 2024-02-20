# The AssetFetch Specification

**AssetFetch** is an HTTP- and JSON-based system for browsing, retrieving and handling/importing digital assets for media creation.
The AssetFetch Protocol aims to provide a standardized way for artists to browse libraries of downloadable assets offered by providers *outside* their current production environment/pipeline, such as those of commercial or non-profit 3D asset vendors, marketplaces or other repositories of models, textures or any other kind of digital assets.

It aims to help in creating an artist experience similar to existing native integrations, such as proprietary import plugins like, with less development overhead in order to increase interoperability between vendors and applications and allow more vendors - especially smaller ones - to offer their assets to artists right in the applications where they need them.

# Project Status: "I just uploaded this."
Currently, the very first draft version (0.1) is available and can be read in [spec.md](./spec.md).
The idea was born out of frustration about the prospect of having to develop a Blender addon JUST for my asset site [ambientCG.com](https://ambientCG.com) when a lot of its actions and behaviors would be very similar to those of the addons for Poliigon or PolyHaven.
Everything here at the moment should really only be regarded as a starting-off point for future testing and discussion about how the transfer of 3D assets from vendors to clients can be made made more open and interoperable.

There are still numerous milestones to hit before a version 1.0 can be released. Among other things...

- Create better examples for basically everything. This includes examples for every element of the specification as well as more general examples and user stories to better illustrate what AssetFetch is, how it works and the value it delivers both for asset vendors and users.

- Create proof-of-concept implementations both for the provider- and the client-side in order to demonstrate the viability of the entire system. This will also inevitably lead to changes and clarifications in the spec as problems are encountered and (hopefully) solved.

- Create more extension-specific datablock definitions for many more formats, both open and application-specific ones (`max`(3DSMax),`ma/mb`(Maya),`uasset`(Unreal Engine),`usda/c/z` (OpenUSD), `gltf/b`(GLTF),...) 

- Create JSON schema documents for every endpoint and datablock to help with validation.

- Create a logo for the standard.

- ...

# JSON Schema

JSON-Schemas for AssetFetch are provided in the `/json-schema` subdirectory of this repository.

# Contributing
Currently the best way to contribute is by opening issues with questions, contradictions in the specifications, suggestions for datablocks or any other thoughts about the specification.