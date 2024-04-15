# 1. Introduction

This document specifies **AssetFetch v0.3**, an HTTP- and JSON-based system for 3D asset discovery, retrieval and handling/import inside of Digital Content Creation (DCC) apps.
The AssetFetch Protocol aims to provide a standardized way for artists to browse libraries of downloadable assets offered by providers *outside* their current production environment or pipeline, such as those of commercial or non-profit 3D asset vendors, marketplaces or other repositories of models, textures or other kinds of assets for digital media production.

## 1.1. Motivation

Acquiring pre-made assets for use in a project usually involves visiting the website of a vendor offering 3D models, material or other resources and downloading one or multiple files to local storage.
These asset files are then manually imported into the desired DCC application, a process which often involves additional steps for unpacking, file organization and adjustments after the initial import such as manually setting up a material from texture maps that came with a model file.

When trying to work with a large volume of third-party assets this workflow can become rather laborious, even more so when trying to experiment with multiple assets to see which works best in a scene.
Recognizing this issue, multiple vendors have started creating bespoke solutions that allow artists to browse an individual vendor's asset library in a much more integrated fashion, for example through an additional window or panel integrated into the graphical user interface in a 3D suite.
This vastly improves the user experience of browsing, downloading and importing assets and helps artists to focus on their core creative objective.

However, these solutions are usually implemented using addons/plugins and are hard-coded to work with one 3D suite and one vendor, which creates a new set of issues:

Vendors wanting to offer this improved user experience for their customers find themselves needing to build and maintain multiple pieces of software with limited opportunities for code reuse as every new plugin must be built within the language, framework and constraints presented by the target host application.

In light of this, many vendors choose to only offer a native integration for one or two applications or no native integrations at all.
This may be because they don't have the resources and skills required or because development of such systems is not justifiable from a business perspective.

Conversely, large vendors who can afford to develop and continuously maintain native integrations for many different DCC applications can benefit from a lock-in effect as only they can provide the convenience and speed that artists are accustomed to - limiting artist's choices.

## 1.2. Vision

The AssetFetch system aims to create an artist experience similar to the existing native integrations with less development overhead in order to increase interoperability between vendors and DCC applications to allow more vendors - especially smaller ones - to offer their assets to artists right in the DCC applications where they need them.

## 1.3. Goals of this specification

These are the goals of the AssetFetch specification, outlined in this document:

- Describe a flexible, extensible way of discovering, filtering and previewing assets.
- Facilitate the *one-time and one-directional transfer* of an asset with all its files from a provider to a client.
- Allow providers to describe the structure of their assets (i.e. how the files they provide should work together) in a machine-readable way that allows for semi- or fully-automated handling of assets on the client-side with the smallest amount of manual adjustments that is achievable. 
<br><br>
- Work without custom code that is specific for one vendor-application combination.
- Make offering assets a low-threshold process for implementors on the provider side.
- Allow implementors on the client side (for whom the implementation is likely harder) to easily get to an MVP-stage and gradually build out their implementations from there.

## 1.4. Non-Goals

In order to maintain focus and make the implementation achievable with a reasonable amount of effort AssetFetch does not want to:

- Act as a full asset management system for project- or studio-internal use, i.e. one that permanently tracks potentially evolving assets within an ongoing production. AssetFetch shares some ideas and data structures from [OpenAssetIO](https://openassetio.org/) but is not meant as a competitor or replacement for it, rather as a supplementary system. It might even be possible to run AssetFetch on top of OpenAssetIO in future versions.
- Act as a new file format for describing complex 3D scenes in great detail. This is left to [OpenUSD](https://openusd.org) or [MaterialX](https://materialx.org/). Instead, the focus lies on describing the interactions and relationships between files with existing, well-known file formats.

# 2. Terminology

This section describes several key terms that will be used throughout this document.

## 2.1. User
>The human who uses an AssetFetch client.

## 2.2. Client
>A piece of software built to interact with the AssetFetch-API of a provider in order to receive resources from it.

## 2.3. Host application
>An application into which the client is integrated.

A client can be a standalone application but in most implementation scenarios it will likely be integrated into another host application, like a 3D suite or other DCC application, in the form of a plugin/addon.
The crucial difference to existing provider-specific plugins/addons is that only one implementation needs to be developed and maintained per application, instead of one per provider-application pairing.
In reality there may of course still be multiple client plugins developed for the same application, but the choice for one of them should have less of an impact.

## 2.4. Provider
>The actor that offers assets by hosting an AssetFetch-compliant HTTP(S)-Endpoint.

This provider can be a commercial platform that is offering 3D assets for sale or an open repository providing content for free.
The provider hosts the AssetFetch API as an HTTP(s)-based service.

## 2.5. Asset
>A reusable *logical* media element in the context of a digital project.

The emphasis is put on the term "logical" to indicate that one asset does not necessarily represent a single file.
It might be composed of one or multiple meshes, textures, bones, particle systems, simulation data, etc. that are kept in multiple files.

- A model of a chair with its mesh and textures is considered one asset.
- An HDRI environment map is considered one asset.
- A character model with textures and a rig is considered one asset.

## 2.6. (Asset-)Implementation
> A concrete collection of components (files) that represents an asset in exactly one way for one specific use case, potentially even just for one specific application.

When describing the transfer of assets from a provider to a client it is common for the provider to have the same asset available in many different variations.

These variations may be:
- Small semantic variations, like different colors or design alterations that do not change the nature of the asset so much that it becomes a new asset.
- Quality variations, like multiple texture resolutions or LODs (Levels of Detail) for a mesh.
- Purely technical variations, like offering the same asset with the same general level of technical fidelity in multiple file formats and file-arrangements for different applications.

Some vendors allow their users to control these parameters with great precision so that they only need to download the asset in exactly the format and quality that is desired.
This exact choice - or rather the collection of files with metadata that is a result of it - is considered an  "**implementation** of an asset".

- An OBJ file containing the LOD1 mesh of a chair along with a set of TIFF texture maps measuring 512x512 pixels each is considered one implementation of the chair asset. Using the LOD0 version instead yields a new implementation of the same chair asset.
- An EXR image with a resolution of 8192x4096 pixels in an equirectangular projection is considered one implementation.
Tonemapping the EXR image into a JPG image yields a new implementation of the same asset.
- A BLEND file containing a character model, its rig and all its textures (again with a specific resolution) all packed into it is considered one implementation.
- A UASSET file containing the same character set up for Unreal Engine instead of Blender is considered a different implementation (of the same asset, since the logical element is still the same character).

## 2.7. (Implementation-)Component
> A piece of digital information, generally a file, that is part of an asset implementation.

- The 512px .TIFF roughness map of the aforementioned chair implementation is one component.
- The EXR file containing the panoramic environment is a component. It happens to be the only component in the implementation of that environment.
- The BLEND file with the character model and textures packed into it is also considered one component since the BLEND file is a black box for any program except Blender.
- When working with archives, the archive itself as well as its contents are considered components.
A ZIP archive with the chair model as an FBX file and its textures as PNG files is represented as one component for the ZIP archive and then one component for each file in it (with some exceptions when using specific archive unpacking configurations).

### 2.7.1. Component "activeness"
Not all components of an implementation must be actively processed by the client in order to use them and are instead handled implicitly by the host application.

- When trying to import an implementation consisting of an OBJ-file, an MTL-file and several material maps into a DCC application, then it is generally sufficient to invoke the application's native OBJ import functionality with the OBJ-file as the target.
The references made inside OBJ-file will prompt the application to handle the MTL-file which then loads the supplemental texture maps without any further explicit invocation.
- Some formats like [OpenUSD](https://openusd.org/) allow for more complex references between files. This way an entire scene can be represented by one "root" file which contains references to other files which in turn reference even more files.

In both of the given examples, only one file would need to be "actively" handled by the user (or by a client trying to automate the user's work) with the remaining work getting delegated to the host application.

When a client instructs its host to load a component and this component causes multiple other components to be loaded (for example a mesh file referencing two textures) then the first component would be called "active" (because from the client's perspective it needed active handling) whereas the components referenced by it are called "passive" (because the AssetFetch client did not need to handle them directly).

## 2.8. Datablock
> A piece of metadata of a certain type and structure that can be attached to most other datastructures defined by AssetFetch.

Datablocks are extremely flexible and sometimes reusable pieces of metadata that enable the communication a broad range of metadata:

- Attributes of providers, assets, implementations or other resources
- Instructions for parsing or otherwise handling specific data
- Relationships between resources










# 3. General Operation

This section describes the general mechanisms by which AssetFetch operates.

## 3.1. Overview

These are the key steps that are necessary to successfully browse for and download an asset from a provider.
The full definition of the mentioned endpoints are covered in the [endpoints section](#5-endpoints).

### 3.1.1. Initialization
The client makes an initial connection to the provider by making a call to an initialization endpoint communicated by the provider to the user through external channels.
This initialization endpoint is freely accessible via HTTP(s) GET without any authentication and communicates key information for further usage of the provider's interface, such as:

- The name and other metadata about the provider itself.
- Whether the provider requires the client to authenticate itself through additional HTTP headers.
- The URI through which assets can be queried.
- What parameters can be used to query for assets.

### 3.1.2. Authentication (optional)
The provider MAY require custom authentication headers, in which case the client MUST send these headers along with every request it performs to that provider, unless the request is directed at the initialization endpoint.
The names of these headers, if any, MUST be declared by the provider during the initialization.
The client obtains the required header values, such as passwords or randomly generated access tokens, from the user through a GUI, from a cache or other mechanism.
See [Security considerations](#10-security-considerations) for more details about credential handling.

### 3.1.3. Connection Status (optional)
If the provider uses authentication, then it MUST offer a connection status endpoint whose URI is communicated during initialization and which the client SHOULD contact at least once after initialization to verify the correctness of the authentication values entered by the user.

The connection status endpoint has two primary uses:

- The provider SHOULD respond with user-specific metadata, such as a username or other account details which the client MAY display to the user to verify to them that they are properly connected to the provider.
- If the provider wants to charge users for downloading assets using a prepaid balance system, then it SHOULD use this endpoint to communicate the user's remaining account balance.

After the initial call the client SHOULD periodically call the connection status endpoint again to receive updated user data or account balance information.

### 3.1.4. Browsing assets
After successful initialization (and possibly authentication) the user enters search parameters which form an asset query.
These parameters were defined by the provider during the initialization step and come in different formats, such as simple text strings or selections from a set of options.
The client then loads a list of available assets from the provider.
This list includes general metadata about every asset, such as a name, a thumbnail image, license and other information.
It also MUST include information on how to query the provider for implementations of that asset.
The user chooses one of the assets they wish to receive.

### 3.1.5. Choosing an implementation
In order to load an asset a specific implementation of that asset needs to be chosen.
The first step of this process involves receiving a list of possible implementations from the provider using the information on how to request it sent by the provider along with the other asset metadata.
The provider MAY request additional parameters for querying implementations in order to filter for asset-specific data like texture resolution, level of detail, etc.
The exact parameters are defined by the provider.
After getting the parameters from the user (if applicable) the client requests the list of available implementations for this asset. 
The provider responds with a list of possible implementations available for this asset and the parameters, such as resolution or other quality metrics, chosen by the user.
The implementations each consist of a list of components, each of which have metadata attached to them, including information about file formats, relationships and downloads.
The client analyzes the metadata declarations of each component in every proposed implementation in order to test it for compatibility.
If at least one implementation turns out to be compatible with the client and its host application, the process can proceed.
If more than one implementation is valid for the given client and its host application, it SHOULD ask the user to make the final choice.
This whole process is comparable to the rarely used [agent-driven content negotiation](https://developer.mozilla.org/en-US/docs/Web/HTTP/Content_negotiation#agent-driven_negotiation) in the HTTP standard.

### 3.1.6. Unlocking (Optional)
The provider MAY allow any user to download any asset for free and without authentication or restrictions, but it MAY also require payment for assets or impose other restrictions or quotas.
To accommodate this, providers are able to mark resources as "unlockable", requiring further deliberate action by the client and user to access the files associated with their components.
Unlocking works by linking individual components to an "unlocking request" (i.e. purchase).
This mapping can be 1-to-1 where every component has its own unlocking query (for example for a texturing website that charges users individually for every texture map they download) or 1-to-many where one unlocking query is unlocking many different component files (for example on a 3D website where purchasing a model usually unlocks all available model files and textures at once).

When responding with the implementation list the provider initially withholds the download information that would normally be sent.
If it does that, then it MUST instead provide a list of possible unlocking queries, the mapping between components and unlocking queries and queries to receive the previously withheld download information for every component after the unlocking has happened.
This method also allows the provider to generate and distribute temporary download links, if it chooses to do so.

The client SHOULD then present the required unlocking queries (along with the accompanying charges that the provider has declared will happen to) to the user.
If the user agrees, the client first performs the unlocking query (or queries) and then queries the provider for the previously withheld datablocks which contain the real download links.

**It should be noted that the AssetFetch does not handle the actual payment itself, users still need to perform any required account- and payment setup with the provider through external means, like the provider's website.**

### 3.1.7. Downloading and Handling
After choosing a suitable implementation and unlocking all of it's datablocks (if required), the client can download the files for every component of the implementation into a newly created dedicated directory on the local workstation on which the client is running.
The choice about where this directory should be created is made between the client and user through configuration and is not part of the specification.

Inside this directory the client SHOULD arrange the files as described by the provider in the implementation metadata to ensure that relative links between files remain intact.

At this point the client can - either by itself or through calls to its host application - handle the files that it obtained.
In the context of a 3D suite this "handling" usually involves importing the data into the current scene or a software-specific repository of local assets.
This processing is aided by the metadata in the datablocks of every component sent by the provider which describes relevant attributes, recommended vendor- or format-specific configurations or relationships between components.

At this point the interaction is complete and the user can start a new query for assets.

## 3.2. Sequence Diagram
The following diagrams illustrate the general flow of information between the user, the client software and the provider as well as the most important actions taken by each party.

### 3.2.1. Simple Version
This diagram shows a simple implementation without any ability for dynamic filtering or dynamically generated implementations and without requiring authentication or unlocking.
All assets are freely available for everyone.

```mermaid
sequenceDiagram

	box Local Workstation
		participant User
		participant Client
	end
	box Remote Server
		participant Provider
	end

    User->>Client: Requests connection to free.example.com/init
	Client->>Provider: Query: free.example.com/init
	Provider->>Client: Response: Initialization data
	
	Client->>Provider: Query: free.example.com/assets
	note right of Client: The asset query URI<br>was included in the<br>initialization data
	Provider->>Provider: Searches its database for assets<br>based on query parameters
	Provider->>Client: Response: List of assets
	Client->>User: Presents asset list
	User->>Client: Selects asset from list
	Client->>Provider: Query: free.example.com/implementations?asset=<asset id>
	note right of Client: The implementations query URI and parameters<br>were included in the asset data
	Provider->>Provider: Loads implementations<br>for this asset from its database
	Provider->>Client: Returns list of possible implementations
	Client->>Client: Validates proposed implementations and<br>selects those that it can handle<br>(based on metadata<br> about file formats and relationships)
	Client->>User: Presents implementation(s)<br>and asks for confirmation
	User->>Client: Confirms asset import
	loop For every component in implementation
		Client->>Provider: Initiates HTTP download of component file
		Provider->>Client: Transmits file
	end
	Client->>Client: Processes files locally based<br>on implementation metadata<br>(usually by importing them<br>into the current project)
	Client->>User: Shows confirmation message
	note left of User: User can now utilize<br>the asset in their project.
```

### 3.2.2. Complete Version

This diagram shows a more complete interaction, including authentication and asset unlocking.

```mermaid
sequenceDiagram

	box Local Workstation
		participant User
		participant Client
	end
	box Remote Server
		participant Provider
	end

    User->>Client: Requests connection to paid.example.com/init
	note left of User: The provider URI might be<br>bookmarked in the client,<br>if it supports that.
    Client->>Provider: Query: paid.example.com/init
	Provider->>Client: Response: Initialization data, containing requirement for authentication
	Client->>User: Presents required headers<br>as a GUI/form
	note left of User: Some data <br>might be cached by the<br> client and does not need<br>to be re-entered. 
	User->>User: Fills out required header values
	User->>Client: Confirms inputs of provider data.

	Client->>Provider: Query: paid.example.com/status
	Provider->>Client: Responds with status data<br>(Login confirmation, username, account balance, ...)

	User->>User: Fills out asset query<br>as defined by provider<br>(tags, categories, ...)
	User->>Client: Confirms choices and requests asset list
	Client->>Provider: Query: paid.example.com/assets?q=<search term>
	note right of Client: The asset query URI<br>was included in the<br>initialization data
	Provider->>Provider: Searches its database for assets<br>based on query parameters
	Provider->>Client: Response: List of assets
	Client->>User: Presents asset list
	User->>Client: Selects asset from list

	Client->>User: Presents available parameters<br>for querying implementations<br>as GUI/form
	User->>User: Fills out implementations query<br>(texture resolution,LOD,...)
	User->>Client: Confirms choices and<br>requests implementations
	Client->>Provider: Query: paid.example.com/implementations?asset=<asset id>&resolution=<resolution>
	note right of Client: The implementations query URI<br>was included in the asset data
	Provider->>Provider: Loads implementations<br>for this asset from its database,<br>based on query
	Provider->>Client: Returns list of possible implementations<br>*without download information*
	Client->>Client: Validates proposed implementations and<br>selects those that it can handle<br>(based on metadata<br> about file formats and relationships)
	Client->>User: Presents implementation(s)<br>and asks for confirmation
	User->>User: Reviews suggested implementation(s)<br>(*price*,files, download size, etc.)
	User->>Client: Confirms asset import

	loop Possibly multiple times, depending on granularity of <br>provider's unlocking model
		Client->>Provider: Query: paid.example.com/unlock?asset=<asset id>&component=<component id>
		Provider->>Client: Confirms the unlocking action.
	end

	loop For every component that <br>had its download-related datablocks withheld
		Client->>Provider: Query: paid.example.com/downloads?asset=<asset id>&component=<component id>
		Provider->>Client: Responds with actual download information<br>(possibly temporarily generated)
	end

	loop For every component
		Client->>Provider: Initiates HTTP download of component file
		Provider->>Client: Transmits file
	end

	Client->>Client: Processes files locally based<br>on implementation metadata<br>(usually by importing them<br>into the current project)
	Client->>User: Confirms asset import
	note left of User: User can now utilize<br>the asset in their project.
	User->>User: Fills out asset query<br>again for next asset, if desired
```










# 4. HTTP Communication

This section describes general instructions for all HTTP communication described in this specification.
The term "HTTP communication" also always includes communication via HTTPS instead of plain HTTP.

## 4.1. Request payloads

The payload of all HTTP requests from a client to a provider MUST be encoded as [`application/x-www-form-urlencoded`](https://url.spec.whatwg.org/#application/x-www-form-urlencoded), the same format that is used by standard HTML forms.

Examples for a valid query payload are shown below. 
```
q=wood,old&min_resolution=512
lod=0
query=&category=marble
```

This encoding for request data is already extremely widespread and can therefore usually be handled using standard libraries, both on the provider- and on the client-side.

## 4.2. Response payloads

The payload of all HTTP responses from a provider MUST be valid [JSON](https://www.json.org/) and SHOULD use the `Content-Type` header `application/json`.
The exact structure of the data for individual endpoints and other API resources is specified in the [Endpoint section](#5-endpoints).

## 4.3. User-Agent

The client SHOULD send an appropriate user-agent header as defined in [RFC 9110](https://www.rfc-editor.org/rfc/rfc9110#field.user-agent).

If the client is embedded in a host application, for example as an addon inside a 3D suite, it SHOULD set its first `product` and `product-version` identifier based on the host application and then describe the product and version of the client plugin itself afterwards.

```
# Examples for plugins/addons:
cinema4d/2024.2 MyAssetFetchPlugin/1.2.3
3dsmax/2023u1 AssetFetchFor3dsMax/0.5.7
blender/4.0.3 BlenderAssetFetch/v17

# Example for a standalone client:
standaloneAssetFetchClient/1.4.2.7
```

## 4.4. Variable and Fixed Queries

In AssetFetch, there are several instances where the provider needs to describe a possible HTTP request that a client can make to perform a certain action or obtain data, such as browsing for assets, unlocking components or downloading files.
In this context, the specification differentiates between "variable" and "fixed" queries.

### 4.4.1. Variable Query

A **variable query** is an HTTP request defined by its URI, method and a payload _that has been (partly) configured by the user_ which is sent by the client to the provider in order to receive data in response.
For this purpose, the provider sends the client a list of parameter values that the client MUST use to construct the actual HTTP query to the provider.
For the client, handling a variable query usually involves drawing a GUI and asking the user to provide the values to be sent to the provider.

A simple example for a variable query is a query for listing assets that allows the user to specify a list of keywords before the request is sent to the provider.

#### 4.4.1.1. Variable Query Parameters

The full field list of a variable query object can be found in the [`variable_query` datablock template](#721-variable_query).

A variable query is composed of its URI, HTTP method and optionally one or multiple parameter definitions that are used to determine the payload of the HTTP request.

Every parameter has a `title` property which the client SHOULD use to communicate the functionality of the given parameter to the user.
The `id` property on the parameter dictates the actual key value that the client MUST use when composing the HTTP request.

The nature of the final value of the parameter is dictated by its `type`.
If the provider offers one or multiple adjustable parameters, it MUST choose one of the following parameter types for each parameter:

- `text`: A string of text with no line breaks (`\r` and/or `\n`). When utilizing a GUI the client SHOULD use a one-line text input field to represent this parameter. The client MUST allow the use of an empty string.
- `boolean`: A binary choice with `true` being represented by the value `1` and `false` with the value `0`. The client MUST NOT send any other response value for this parameter. When utilizing a GUI the client SHOULD use a tick-box or similar kind of menu item to represent this parameter.
- `select`: A list of possible choices, each represented by a `value` which is the actual parameter value that the client MUST include in its HTTP request if the user chooses the choice in question and a `title` which the client SHOULD use to represent the choice to the user. When utilizing a GUI the client SHOULD use a drop-down or similar kind of menu to represent this parameter.
- `fixed`: A fixed value that the client MUST include in its request verbatim. The client MAY reveal this value to the user, but MUST NOT allow any changes to this value.

### 4.4.2. Fixed Query

The full field list of a fixed query object can be found in the [`fixed_query` datablock template](#722-fixed_query).

A **fixed query** is an HTTP(S) request defined by its URI, method and a payload _that is not configurable by the user_  which is sent by the client to the provider in order to receive data in response.

In this case the provider only transmits the description of the query to the client whose only decision is whether or not to actually send the query with the given parameters to the provider.

A typical example for a fixed query is a download option for a file where the client only has the choice to invoke or not invoke the download.

## 4.5. HTTP Codes and Error Handling

Every response sent from an AssetFetch provider MUST use HTTP Status codes appropriately.

In concrete terms, this means:

- If a provider managed to successfully process the query then the response code SHOULD be `200 - OK`. Even if the query sent by the client leads to zero results in the context of a search with potentially zero to infinitely many results, the response code SHOULD still be `200 - OK`.
- If a provider receives a query that references a specific resource which does not exist, such as a query for implementations of an asset that the provider does not recognize, it SHOULD respond with code `404 - Not Found`.
- If the provider can not parse the query data sent by the client properly, it SHOULD respond with code `400 - Bad Request`.
- If a provider receives a query an any other endpoint than the initialization endpoint without one of the headers it defined as required during the initialization it SHOULD send status code `401 - Unauthorized`. This indicates that the client is unaware of required headers and SHOULD cause the client to contact the initialization endpoint for that provider again in order to receive updated information about required headers.
- If a provider receives a query that does have all the requested headers, but the header's values could not be recognized or do not entail the required permissions to perform the requested query, it SHOULD respond with code `403 - Forbidden`. If the rejection of the request is specifically related to monetary requirements - such as the lack of a paid subscription, lack of sufficient account balance or the attempt to perform a download that has not been unlocked, the provider MAY respond with code `402 - Payment Required` instead.

If a client receives a response code that indicates an error on any query (`4XX`/`5XX`) it SHOULD pause its operation and display a message regarding this incident to the user.
This message SHOULD contain the contents of the `message` and `id` field in the response's [metadata](#511-the-meta-template), if they have content.










# 5. Endpoints

This section outlines general information about AssetFetch endpoints along with the specific structural requirements for every endpoint.

## 5.1. About Endpoints

The interaction model described in the [General Operation](#3-general-operation) section principally implies that there are three kinds of HTTP(s)-based endpoints that a provider MUST implement:

- An initialization endpoint
- An endpoint for querying assets
- An endpoint for querying implementations of one specific asset

Depending on which features it wants to use, the provider MUST implement:
- A connection status endpoint if it wants to use custom headers for authentication
- An endpoint for unlocking resources
- An endpoint for obtaining previously withheld datablocks if it wants to support asset unlocking (i.e. purchases)

The URI for the initialization endpoint is communicated by the provider to the user through external means (such as listing it on the provider's website).
The URIs and parameters for all subsequent endpoints are not defined explicitly by the specification and are communicated from the provider to the client.
This gives the provider great flexibility in how to structure its data and backend implementation.

### 5.1.1. The `meta` template
All provider responses on all endpoints MUST carry the `meta` field to communicate key information about the current response.

| Field         | Format | Required | Description                                                                                                                               |
| ------------- | ------ | -------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `response_id` | string | no       | An ID for this specific response from the provider.                                                                                       |
| `version`     | string | yes      | The version of AssetFetch that this response is intended for.                                                                             |
| `kind`        | string | yes      | The kind of data that is being transmitted with this response. The exact value of this field is specified individually for each endpoint. |
| `message`     | string | no       | An arbitrary message to attach to this response.                                                                                          |

The `response_id` field is designed to aid with logging and troubleshooting, should the need arise.
The provider MAY set this field, in which case they SHOULD keep a log of the responses and their ids, especially in the case of an error.

If a request fails, the provider SHOULD use the `message` field to communicate more details for troubleshooting.

Clients SHOULD display the `response_id` and `message` fields to the user if a query was unsuccessful, as indicated by the HTTP status code.

### 5.1.2. The `datablock_collection` template
This object contains most of the relevant information for any resource and always has the same general structure, described in this section.

| Field                                | Format          | Required | Description                                                                |
| ------------------------------------ | --------------- | -------- | -------------------------------------------------------------------------- |
| \<string-key\>                       | object or array | yes      | Exact structure is defined in the [Datablocks section](#8-datablock-index) |
| \<string-key\>                       | object or array | yes      | Exact structure is defined in the [Datablocks section](#8-datablock-index) |
| ... (arbitrary number of datablocks) |

Every key of this data object is the identifier for the datablock stored in that key's field.

The example below illustrates an object called `data` whose structure follows the `datablock_collection` template with two datablocks (`block_type_1` and `block_type_2`) which have a varying structure.

```
{
    "data":{
        "block_type_1":{
            "example_key": "example_value"
        },
        "block_type_2.a":{
            "example_array": [1,2,4],
            "example_object": {
                "a": 7
            }
        }
    }
}
```

## 5.2. Initialization 

This endpoint is the first point of contact between a client and a provider.
The provider MUST NOT require any kind of authentication for interaction with it.
It's URI is initially typed or copy-pasted by the user into a client and is used to communicate key details about the provider as well as how the interaction between client and provider should proceed.

The response on this endpoint MUST have the following structure:

| Field  | Format                 | Required | Description                                                                                                                                                                                                       |
| ------ | ---------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `meta` | `meta`                 | yes      | Metadata, kind: `initialization`.                                                                                                                                                                                 |
| `id`   | string                 | yes      | An id that identifies this provider. It MUST match the regular expression `[a-z0-9-\.]`. Providers SHOULD use a domain name (e.g. `example.com` or `sub.example.com`) as the ID, if applicable in their use-case. |
| `data` | `datablock_collection` | yes      |                                                                                                                                                                                                                   |

The following datablocks are to be included in the `data` field:

| Requirement Level                    | Datablocks                                         |
| ------------------------------------ | -------------------------------------------------- |
| MUST                                 | `asset_list_query`                                 |
| SHOULD                               | `text`                                             |
| MAY                                  | `branding`, `authors`, `license`, `web_references` |
| MUST, only if authentication is used | `provider_configuration`                           |


## 5.3. Asset List

The URI and available parameters for this endpoint are communicated by the server to the client using the `asset_list_query` datablock on the initialization endpoint.

The response on this endpoint MUST have the following structure:

| Field    | Format                 | Required | Description                   |
| -------- | ---------------------- | -------- | ----------------------------- |
| `meta`   | `meta`                 | yes      | Metadata, kind: `asset_list`. |
| `data`   | `datablock_collection` | yes      |                               |
| `assets` | Array of `asset`       | yes      |                               |

The following datablocks are to be included in the `data` field:

| Requirement Level | Datablocks                                        |
| ----------------- | ------------------------------------------------- |
| MAY               | Any or all of `next_query`, `response_statistics` |

The `assets` field MUST NOT contain more than 100 items for one response.
If the provider finds more assets than 100 assets which match the query it MAY use the `next_query` datablock to define a fixed query that the client can use to fetch more results.

### 5.3.1. `asset` Structure

Every `asset` object MUST have the following structure:

| Field  | Format                 | Required | Description                                                                 |
| ------ | ---------------------- | -------- | --------------------------------------------------------------------------- |
| `id`   | string                 | yes      | Unique id for this asset. Must match the regular expression `[a-z0-9_-\.]+` |
| `data` | `datablock_collection` | yes      |                                                                             |

The `id` field MUST be unique among all assets for this provider.
Clients MAY use this id when storing and organizing files on disk.
Clients MAY use the id as a display title, but SHOULD prefer the `title` field in the asset's `text` datablock, if available.

The following datablocks are to be included in the `data` field:

| Requirement Level | Datablocks                                                                          |
| ----------------- | ----------------------------------------------------------------------------------- |
| MUST              | `implementation_list_query`                                                         |
| SHOULD            | `preview_image_thumbnail`, `text`                                                   |
| MAY               | `preview_image_supplemental`, `license`, `authors`, `dimensions.*`,`web_references` |


## 5.4. Implementation List

This endpoint returns one or several implementations for one specific asset.
The URI and available parameters for this endpoint are communicated by the server to the client using the `implementation_list_query` datablock on the corresponding asset in the asset list endpoint.

| Field             | Format                    | Required | Description                                              |
| ----------------- | ------------------------- | -------- | -------------------------------------------------------- |
| `meta`            | `meta`                    | yes      | Metadata, kind: `implementation_list`.                   |
| `data`            | `datablock_collection`    | yes      | Datablocks that apply to the entire implementation list. |
| `implementations` | Array of `implementation` | yes      |                                                          |

The following datablocks are to be included in the `data` field:

| Requirement Level                           | Datablocks            |
| ------------------------------------------- | --------------------- |
| MUST, only if asset unlocking is being used | `unlock_queries`      |
| MAY                                         | `response_statistics` |

### 5.4.1. `implementation` Structure

Every `implementation` object MUST have the following structure:

| Field        | Format                 | Required | Description                                                                             |
| ------------ | ---------------------- | -------- | --------------------------------------------------------------------------------------- |
| `id`         | string                 | yes      | A unique id for this implementation. Must match the regular expression `[a-z0-9_-\.]+`. |
| `data`       | `datablock_collection` | yes      | Datablocks that apply to this specific implementation.                                  |
| `components` | Array of `component`   | yes      |                                                                                         |

The `id` field MUST be unique among all possible implementations the provider can offer for this asset, *even if not all of them are included in the returned implementation list*.
The id may be reused for an implementation of a *different* asset.
Clients MAY use this id when storing and organizing files on disk.
Clients MAY use the id as a display title, but SHOULD prefer the `title` field in the asset's `text` datablock, if available.

The following datablocks are to be included in the `data` field:

| Requirement Level | Datablocks |
| ----------------- | ---------- |
| SHOULD            | `text`     |

### 5.4.2. `component` Structure

Every `component` object MUST have the following structure:

| Field  | Format     | Required | Description                                                                        |
| ------ | ---------- | -------- | ---------------------------------------------------------------------------------- |
| `id`   | string     | yes      | A unique id for this component. Must match the regular expression `[a-z0-9_-\.]+`. |
| `data` | datablocks | yes      | Datablocks for this specific component.                                            |

The `id` field MUST be unique among all components inside one implementation, but MAY be reused for a component in a different implementation.
Clients MAY use this id when storing and organizing files on disk.
Clients MAY use this field as a display title, but SHOULD prefer the `title` field in the asset's `text` datablock, if available.

The following datablocks are to be included in the `data` field:

| Requirement Level | Datablocks                                                           |
| ----------------- | -------------------------------------------------------------------- |
| MUST              | `file_info`,`file_handle`, `file_fetch.*`                            |
| MAY               | `environment_map`, `loose_material.*`, `mtlx_apply`,`text`, `unlock` |

# 6. Additional Endpoints

Additional endpoint types can be used to perform certain actions or retrieve additional information.


## 6.1. Unlocking Endpoint

| Field  | Format                 | Required | Description               |
| ------ | ---------------------- | -------- | ------------------------- |
| `meta` | `meta`                 | yes      | Metadata, kind: `unlock`. |
| `data` | `datablock_collection` | no       | Datablocks.               |

This endpoint is invoked to perform an "unlocking" (usually meaning a "purchase") of a resource.
After calling it the client can expect to resolve all previously withheld downloads using the endpoint for unlocked data specified in the `file_fetch.download_post_unlock` datablock.
The URI and parameters for this endpoint are communicated through the `unlock_queries` datablock.

This endpoint currently does not use any datablocks.
Only the HTTP status code and potentially the data in the `meta` field are used to evaluate the success of the request.

## 6.2. Unlocked Data Endpoint

| Field  | Format                 | Required | Description                     |
| ------ | ---------------------- | -------- | ------------------------------- |
| `meta` | `meta`                 | yes      | Metadata, kind:`unlocked_data`. |
| `data` | `datablock_collection` | yes      | Datablocks.                     |

This endpoint type responds with the previously withheld data for one component, assuming that the client has made all the necessary calls to the unlocking endpoint(s).
It gets called by the client for every component that had an `file_fetch.download_post_unlock` datablock assigned to it and returns the "real" `file_fetch.download` datablock (which may be temporarily generated).

The following datablocks are to be included in the `data` field:

| Requirement Level | Datablocks            |
| ----------------- | --------------------- |
| MUST              | `file_fetch.download` |


## 6.3. Connection Status Endpoint

| Field  | Format                 | Required | Description                         |
| ------ | ---------------------- | -------- | ----------------------------------- |
| `meta` | `meta`                 | yes      | Metadata, kind: `connection_status` |
| `data` | `datablock_collection` | yes      | Datablocks.                         |

The URI and parameters for the balance endpoint are communicated by the provider to the client through the `provider_configuration` datablock.

The following datablocks are to be included in the `data` field:

| Requirement Level                                                  | Datablocks       |
| ------------------------------------------------------------------ | ---------------- |
| SHOULD, if the provider uses a prepaid system for unlocking assets | `unlock_balance` |
| MAY                                                                | `user`           |










# 7. Datablocks

## 7.1. Datablock names

The name of a datablock MUST be a string composed of small alphanumerical characters, underscores and dots.
Datablock names MUST contain either 0 or 1 instance of the dot (`.`) character which indicates that a datablock has multiple variations.
One resource MUST NOT have two datablocks that share the same string *before* the dot separator.

The resulting regular expression from these rules is `^[a-z0-9_]+(\.[a-z0-9_]+)?$`.

## 7.2. Datablock value templates
This section describes additional data types that can be used within other datablocks.
They exist to eliminate the need to re-specify the same data structure in two different datablock definitions.
*The templates can not be used directly as datablocks under their template name, though some datablock completely inherit their structure under a new name.*

### 7.2.1. `variable_query`
This template describes an HTTP query whose parameters are controllable by the user.
See [Variable and Fixed Queries](#44-variable-and-fixed-queries) for more details.

| Field        | Format               | Required | Description                                 |
| ------------ | -------------------- | -------- | ------------------------------------------- |
| `uri`        | string               | yes      | The URI to send the request to.             |
| `method`     | string               | yes      | One of `get`, `post`                        |
| `parameters` | array of `parameter` | yes      | The configurable parameters for this query. |

#### 7.2.1.1. `parameter` Structure
A parameter describes the attributes of one parameter for the query and how the client can present this to its user.

| Field     | Format            | Required                      | Description                                                                                                                                                                                                          |
| --------- | ----------------- | ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `type`    | string            | yes                           | One of `text`, `boolean`, `select`, `fixed`                                                                                                                                                                          |
| `id`      | string            | yes                           | The id of the HTTP parameter. It MUST be unique among the parameters of one variable query. The client MUST use this value as a the key when sending a response using this parameter.                                |
| `title`   | string            | no                            | The title that the client SHOULD display to the user to represent this parameter.                                                                                                                                    |
| `default` | string            | no                            | The default value for this parameter. It MUST be one of the `value` fields outlined in `choices` if type `select` is bing used. It becomes the only possible value for this parameter if type `fixed` is being used. |
| `choices` | array of `choice` | yes, if `select` type is used | This field contains all possible choices when the `select` type is used. In that case it MUST contain at least one `choice` object, as outlined below.                                                               |

#### 7.2.1.2. `choice` Structure
A single choice for a `select` type parameter.

| Field   | Format | Required | Description                                                                                   |
| ------- | ------ | -------- | --------------------------------------------------------------------------------------------- |
| `value` | string | yes      | The value that the client MUST use in its HTTP response if the user has selected this choice. |
| `title` | string | yes      | The title that the client SHOULD display to the user to represent this choice.                |

### 7.2.2. `fixed_query`
This template describes a fixed query that can be sent by the client to the provider without additional user input or configuration.
See [Variable and Fixed Queries](#44-variable-and-fixed-queries) for more details.

| Field     | Format                        | Required | Description                                         |
| --------- | ----------------------------- | -------- | --------------------------------------------------- |
| `uri`     | string                        | yes      | The URI to contact for getting more results.        |
| `method`  | string                        | yes      | MUST be one of `get` or `post`                      |
| `payload` | object with string properties | no       | The keys and values for the payload of the request. |










# 8. Datablock Index

This section displays all datablocks that are currently part of the standard.

The text in brackets before the title indicates which kind of AssetFetch resources this block can be applied to.
To aid with reading this list, exclamation marks and question marks are used to indicate whether this datablock MUST be applied to that resource (!) or if it SHOULD/MAY (?) be applied.
A star (*) is used to indicate that there are special rules for when/if this datablock is to be used.


## 8.1. Configuration and authentication-related datablocks

### 8.1.1. `provider_configuration`
Headers that the provider expects to receive from the client on every subsequent request.

This datablock has the following structure:

| Field                          | Format            | Required | Description                                                                                                       |
| ------------------------------ | ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------- |
| `headers`                      | Array of `header` | yes      | List of headers that the client MAY or MUST (depending on configuration) send to the provider on any request.     |
| `connection_status_query`      | `fixed_query`     | yes      | Query to use for checking whether the provided headers are valid und for obtaining connection status information. |
| `header_acquisition_uri`       | string            | no       | A URI that the client MAY offer to open in the user's web browser to help them obtain the header values.          |
| `header_acquisition_uri_title` | string            | no       | Title for the `acquisition_uri`.                                                                                  |


#### 8.1.1.1. `header` structure

| Field          | Format  | Required            | Description                                                                                                                                                                |
| -------------- | ------- | ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`         | string  | yes                 | Name of the header                                                                                                                                                         |
| `default`      | string  | no                  | Default value as a suggestion to the client.                                                                                                                               |
| `is_required`  | boolean | yes                 | Indicates if this header is required.                                                                                                                                      |
| `is_sensitive` | boolean | yes                 | Indicates if this header is sensitive and instructs the client to take appropriate measures to protect it. See [Storing Sensitive Headers](#101-storing-sensitive-headers) |
| `prefix`       | string  | no                  | Prefix that the client should prepend to the value entered by the user when sending it to the provider. The prefix MUST match the regular expression `[a-zA-Z0-9-_\. ]*`.  |
| `suffix`       | string  | no                  | Suffix that the client should append to the value entered by the user when sending it to the provider.The suffix MUST match the regular expression `[a-zA-Z0-9-_\. ]*`.    |
| `title`        | string  | no                  | Title that the client SHOULD display to the user.                                                                                                                          |
| `encoding`     | string  | no, default=`plain` | The encoding that the client MUST apply to the header value and the prefix/suffix. MUST be one of `plain` or `base64`.                                                     |

### 8.1.2. `provider_reconfiguration`

This datablock allows the provider to communicate to the client that a new set of headers that it MUST sent along with every request instead of those entered by the user until a new initialization is performed.
The client MUST fully replace the values defined using the requirements from the original `provider_configuration` datablock with the new values defined in this datablock.

| Field     | Format | Required | Description                                                                                                                                             |
| --------- | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `headers` | Object | yes      | An object whose properties MUST all be strings. The keys indicate the new header names, the property values represent the new header values to be used. |


These new headers effectively act like cookies used on web sites.
Providers SHOULD therefore only use this datablock for purposes that are strictly required for the communication to work and MUST consider the potential legal implications when deciding to use this datablock for other purposes such as tracking or analytics.
Clients MAY require the user to confirm the new header values before starting to send them.


### 8.1.3. `user`

This datablock allows the provider to transmit information about the user to the client, usually to allow the client to show the data to the user for confirmation that they are properly connected to the provider.

| Field              | Format | Required | Description                                                                                                            |
| ------------------ | ------ | -------- | ---------------------------------------------------------------------------------------------------------------------- |
| `display_name`     | string | no       | The name of the user to display.                                                                                       |
| `display_tier`     | string | no       | The name of the plan/tier/subscription/etc. that this user is part of, if applicable for the provider.                 |
| `display_icon_uri` | string | no       | URI to an image with an aspect ratio of 1:1, for example a profile picture or icon representing the subscription tier. |

## 8.2. Browsing-related datablocks

These datablocks all relate to the process of browsing for assets or implementations.

### 8.2.1. `asset_list_query`
Describes the variable query for fetching the list of available assets from a provider.
It follows the `variable_query` template.

### 8.2.2. `implementation_list_query`
Describes the variable query for fetching the list of available implementations for an asset from a provider.
It follows the `variable_query` template.

### 8.2.3. `next_query`
Describes a fixed query to fetch more results using the same parameters as the current query.
The response to this query from the provider MUST be of the same `kind` as the query in which this datablock is contained.
Follows the `fixed_query` template.

### 8.2.4. `response_statistics`

This datablock contains statistics about the current response.
It can be used to communicate the total number of results in a query where not all results can be communicated in one response and are instead deferred using `next_query`.

| Field                | Format | Required | Description                                                                                                                                                                                            |
| -------------------- | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `result_count_total` | int    | yes      | The total number of results. This number should include the total number of results matching the given query, even if not all results are returned due to pagination using the `query_next` datablock. |


## 8.3. File-related datablocks

### 8.3.1. `file_info`

This datablock contains information about any kind of file.

| Field       | Format  | Required | Description                                            |
| ----------- | ------- | -------- | ------------------------------------------------------ |
| `length`    | integer | no       | The length of the file in bytes.                       |
| `extension` | string  | yes      | The file extension indicating the format of this file. |

The `extension` field MUST include a leading dot (`.obj` would be correct,`obj` would not be correct), and, if necessary to fully communicate the format,
MUST include multiple dots for properly expressing certain "combined" file formats (eg. `.tar.gz` for a gzipped tar-archive).

### 8.3.2. `file_handle`

This datablock indicates how this file should behave during the import process.
The full description of component handling can be found in the [component handling section](#933-handling-component-files).

| Field        | Format | Required                                         | Description                                                                                |
| ------------ | ------ | ------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| `local_path` | string | yes, unless `behavior=archive_unpack_referenced` |                                                                                            |
| `behavior`   | string | yes                                              | One of `single_active`,`single_passive`,`archive_unpack_fully`,`archive_unpack_referenced` |

**If `behavior` is `single_*`:**

The `local_file_path` MUST include the full name that the file should take in the destination and it MUST NOT start with a "leading slash".
It MUST NOT contain relative path references (`./` or `../`) anywhere within it.

`example.txt` or `sub/dir/example.txt` would be correct.
`/example.txt`, `./example.txt` or `/sub/dir/example.txt` would be incorrect.

**If `behavior` is `archive_*`:**

The `local_path` MUST end with a slash ("trailing slash") and MUST NOT start with a slash (unless it targets the root of the asset directory in which case the `local_path` is simply `/`).
It MUST NOT contain relative path references (`./` or `../`) anywhere within it.

`/`, `contents/` or `my/contents/` would be correct.
`contents`,`./contents/`,`./contents`,`my/../../contents` or `../contents` would all be incorrect.

### 8.3.3. `file_fetch.download`

This datablock indicates that this is a file which can be downloaded directly using the provided query.

The full description of component handling can be found in the [component handling section](#933-handling-component-files).

The structure of this datablock follows the `fixed_query` template.

### 8.3.4. `file_fetch.download_post_unlock`

This datablock links the component to one of the unlocking queries defined in the `unlock_queries` datablock on the implementation list.
It indicates that when the referenced unlock query has been completed, the *real* `file_fetch.download` datablock can be received by performing the fixed query in `unlocked_data_query`

| Field                 | Format        | Required | Description                                                                                                                                                                                                                                    |
| --------------------- | ------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `unlock_query_id`     | string        | yes      | The id of the unlocking query in the `unlock_queries` datablock. This indicates that the query defined there MUST be run before attempting to obtain the remaining datablocks (with the download information) using the `unlocked_data_query`. |
| `unlocked_data_query` | `fixed_query` | yes      | The query to fetch the previously withheld `file_fetch.download` datablock for this component if the unlocking was successful.                                                                                                                 |


### 8.3.5. `file_fetch.from_archive`
This datablock indicates that this component represents a file from within an archive that needs to be downloaded separately.
More about the handling in the [import and handling section](#9-implementation-analysis-and-handling).

| Field                  | Format | Required                                                                                                                                                                                                                                                                                           | Description                                                                           |
| ---------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `archive_component_id` | string | yes                                                                                                                                                                                                                                                                                                | The id of the component representing the archive that this component is contained in. |
| `component_path`       | string | The location of the file inside the referenced archive. This MUST be the path to the file starting at the root of its archive. It MUST NOT start with a leading slash and MUST include the full name of the file inside the archive. It MUST NOT contain relative path references (`./` or `../`). |

## 8.4. Display related datablocks

These datablocks relate to how assets and their details are displayed to the user.

### 8.4.1. `text`
General text information to be displayed to the user.

| Field         | Format | Required | Description                                    |
| ------------- | ------ | -------- | ---------------------------------------------- |
| `title`       | string | yes      | A title for the datablock's subject.           |
| `description` | string | no       | A description text for the datablocks subject. |


### 8.4.2. `web_references`
References to external websites for documentation or support.

An array of objects each of which MUST follow this format:
| Field      | Format | Required | Description                                                                                                   |
| ---------- | ------ | -------- | ------------------------------------------------------------------------------------------------------------- |
| `title`    | string | yes      | The title to display for this web reference.                                                                  |
| `uri`      | string | yes      | The URL to be opened in the users browser.                                                                    |
| `icon_uri` | string | yes      | URL to an image accessible via HTTP GET. The image's media type SHOULD be one of `image/png` or `image/jpeg`. |

### 8.4.3. `branding`
Brand information about the provider.

| Field             | Format | Required | Description                                                                                                                   |
| ----------------- | ------ | -------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `color_accent`    | string | no       | Color for the provider, hex string in the format 'abcdef' (no #)                                                              |
| `logo_square_uri` | string | no       | URI to a square logo. It SHOULD be of the mediatype `image/png` and SHOULD be transparent.                                    |
| `logo_wide_uri`   | string | no       | URI to an image with an aspect ratio between 2:1 and 4:1. SHOULD be `image/png`, it SHOULD be transparent.                    |
| `banner_uri`      | string | no       | URI to an image with an aspect ratio between 2:1 and 4:1. SHOULD be `image/png` or `image/jpg`. It SHOULD NOT be transparent. |

### 8.4.4. `license`
Contains license information.
When attached to an asset, it means that the license information only applies to that asset, when applied to a provider, it means that the license information applies to all assets offered through that provider.

| Field          | Format | Required | Description                                                                                               |
| -------------- | ------ | -------- | --------------------------------------------------------------------------------------------------------- |
| `license_spdx` | string | no       | MUST be an [SPDX license identifier](https://spdx.org/licenses/) or be left unset/null if not applicable. |
| `license_uri`  | string | no       | URI which the client SHOULD offer to open in the user's web browser to learn more about the license.      |

### 8.4.5. `authors`

This datablock can be used to communicate the author(s) of a particular asset.

Array of objects that MUST have this structure:

| Field  | Format | Required | Description                                                     |
| ------ | ------ | -------- | --------------------------------------------------------------- |
| `name` | string | yes      | Name of the author.                                             |
| `uri`  | string | no       | A URI for this author, for example a profile link.              |
| `role` | string | no       | The role that the author has had in the creation of this asset. |

### 8.4.6. `dimensions.3d`
Contains general information about the physical dimensions of a three-dimensional asset. Primarily intended as metadata to be displayed to users, but MAY also be used by the client to scale mesh data.

An object that MUST conform to this format:
| Field      | Format | Required | Description                    |
| ---------- | ------ | -------- | ------------------------------ |
| `width_m`  | float  | yes      | Width of the referenced asset  |
| `height_m` | float  | yes      | Height of the referenced asset |
| `depth_m`  | float  | yes      | Depth of the referenced asset  |

### 8.4.7. `dimensions.2d`
Contains general information about the physical dimensions of a two-dimensional asset. Primarily intended as metadata to be displayed to users, but MAY also be used by the client to scale mesh-,texture-, or uv data.

An object that MUST conform to this format:
| Field      | Format | Required | Description                    |
| ---------- | ------ | -------- | ------------------------------ |
| `width_m`  | float  | yes      | Width of the referenced asset  |
| `height_m` | float  | yes      | Height of the referenced asset |

### 8.4.8. `preview_image_supplemental`
Contains a list of preview images with `uri`s and `alt`-Strings associated to the asset.

An array where every field must conform to the following structure:
| Field | Format | Required | Description                                                                                                   |
| ----- | ------ | -------- | ------------------------------------------------------------------------------------------------------------- |
| `alt` | string | no       | An "alt" String for the image.                                                                                |
| `uri` | string | yes      | URL to an image accessible via HTTP GET. The image's media type SHOULD be one of `image/png` or `image/jpeg`. |

### 8.4.9. `preview_image_thumbnail`
Contains information about a thumbnail for an asset. The thumbnail can be provided in multiple resolutions.

An object that MUST conform to this format:
| Field  | Format | Required | Description                    |
| ------ | ------ | -------- | ------------------------------ |
| `alt`  | string | no       | An "alt" String for the image. |
| `uris` | object | yes      | See structure described below. |

#### 8.4.9.1. `uris` Structure

The `uris` field MUST be an object whose keys are strings containing an integer and whose values are strings.
The object MUST have at least one member.
The key represents the resolution of the thumbnail, the value represents the URI for the thumbnail image in this resolution.
The thumbnail image SHOULD be a square.
If the image is not a square, its key SHOULD be set based on the pixel count of its longest site.
The image's media type SHOULD be one of `image/png` or `image/jpeg`.
If the provider does not have insight into the dimensions of the thumbnail that it is referring the client to, it SHOULD use use the key `0` for the thumbnail url.

## 8.5. File handling and relationship datablocks

These datablocks describe how files relate to each other.
In many cases the relationships can be represented purely by placing component files adjacently in one directory and making only some of them "active", but in some cases it is necessary to declare relationships explicitly in AssetFetch.

### 8.5.1. `loose_environment`
The presence of this datablock on a component indicates that it is an environment map.
This datablock only needs to be applied if the component is a "bare file", like (HDR or EXR), not if the environment is already wrapped in another format with native support.
An object that MUST conform to this format:
| Field        | Format | Required | Description                             |
| ------------ | ------ | -------- | --------------------------------------- |
| `projection` | string | yes      | One of `equirectangular`, `mirror_ball` |

### 8.5.2. `loose_material.define`

This datablock is applied to a component that is part of a loose material, most likely a material map.
It indicates which role the component should play in this material.

| Field           | Format | Required | Description                                                                                                                               |
| --------------- | ------ | -------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `material_name` | string | yes      |                                                                                                                                           |
| `map`           | string | yes      | `albedo` `roughness` `metallic` `diffuse` `glossiness` `specular` `height` `normal+y` `normal-y` `opacity` `ambient_occlusion` `emission` |
| `colorspace`    | string | no       | One of `srgb`, `linear`                                                                                                                   |

### 8.5.3. `loose_material.apply`

When applied to a component, it indicates that this component uses one or multiple materials defined using `loose_material.define` datablocks.

The datablock is an **array of objects** with this structure:

| Field                  | Format | Required | Description                                                                                                                           |
| ---------------------- | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `material_name`        | string | yes      | Name of the material used in the definition datablocks                                                                                |
| `apply_selectively_to` | string | no       | Indicates that the material should only be applied to a part of this component, for example one of multiple objects in a `.obj` file. |

### 8.5.4. `mtlx_apply`
When applied to a component, it indicates that this component makes use of a material defined in mtlx document represented by another component.

| Field                  | Format | Required | Description                                                                                                                           |
| ---------------------- | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `mtlx_component_id`    | string | yes      | Id of the component that represents the mtlx file.                                                                                    |
| `mtlx_material`        | string | no       | Optional reference for which material to use from the mtlx file, if it contains multiple.                                             |
| `apply_selectively_to` | string | no       | Indicates that the material should only be applied to a part of this component, for example one of multiple objects in a `.obj` file. |

## 8.6. File-format specific datablocks

These datablocks relate to one specific file format.

### 8.6.1. `format.blend`
Information about files with the extension `.blend`.
This information is intended to help the client understand the file.

| Field      | Format            | Required | Description                                                                                                       |
| ---------- | ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------- |
| `version`  | string            | no       | Blender Version in the format `Major.Minor.Patch` or `Major.Minor` or `Major`                                     |
| `is_asset` | boolean           | no       | `true` if the blend file contains object(s) marked as an asset for Blender's own Asset Manager. (default=`false`) |
| `targets`  | array of `target` | no       | Array containing the blender structures inside the file that are relevant to the asset.                           |

#### 8.6.1.1. `target` Structure

| Field   | Format            | Required | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| ------- | ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `kind`  | `string`          | yes      | One of `actions`, `armatures`, `brushes`, `cache_files`, `cameras`, `collections`, `curves`, `fonts`, `grease_pencils`, `hair_curves`, `images`, `lattices`, `lightprobes`, `lights`, `linestyles`, `masks`, `materials`, `meshes`, `metaballs`, `movieclips`, `node_groups`, `objects`, `paint_curves`, `palettes`, `particles`, `pointclouds`, `scenes`, `screens`, `simulations`, `sounds`, `speakers`, `texts`, `textures`, `volumes`, `workspaces`, `worlds` |
| `names` | Array of `string` | yes      | List of the names of the resources to import.                                                                                                                                                                                                                                                                                                                                                                                                                     |

### 8.6.2. `format.usd`
Information about files with the extension `.usd`.

| Field      | Format  | Required | Description                                                                |
| ---------- | ------- | -------- | -------------------------------------------------------------------------- |
| `is_crate` | boolean | no       | Indicates whether this file is a "crate" (like .usdc) or not (like .usda). |

### 8.6.3. `format.obj`
Information about files with the extension `.obj`.

| Field     | Format | Required | Description                                                        |
| --------- | ------ | -------- | ------------------------------------------------------------------ |
| `up_axis` | string | yes      | Indicates which axis should be treated as up. MUST be `+y` or `+z` |


## 8.7. Unlocking-related datablocks

These datablocks are used if the provider is utilizing the asset unlocking system in AssetFetch.

*Note that the `file_fetch.download_unlocked` datablock is also related to the unlocking system but is [grouped with the other `file_fetch.*` datablocks](#83-file-related-datablocks).* 

### 8.7.1. `unlock_balance`
Information about the user's current account balance.

| Field                | Format | Required | Description                                                                                                 |
| -------------------- | ------ | -------- | ----------------------------------------------------------------------------------------------------------- |
| `balance`            | number | yes      | Balance.                                                                                                    |
| `balance_unit`       | string | yes      | The currency or name of token that's used by this provider to be displayed alongside the price of anything. |
| `balance_refill_uri` | string | yes      | URL to direct the user to in order to refill their prepaid balance, for example an online purchase form.    |

### 8.7.2. `unlock_queries`

This datablock contains the query or queries required to unlock all or some of the components in this implementation list.

This datablock is **an array** consisting of `unlock_query` objects.

#### 8.7.2.1. `unlock_query` structure

| Field                       | Format        | Required                 | Description                                                                                                                                                                                    |
| --------------------------- | ------------- | ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`                        | string        | yes                      | This is the id by which `file_fetch.download_post_unlock` datablocks will reference this query.                                                                                                |
| `unlocked`                  | boolean       | yes                      | Indicates whether the subject of this datablock is already unlocked (because the user has already made this query and the associated purchase in the past ) or still locked.                   |
| `price`                     | number        | only if `unlocked=False` | The price that the provider will charge the user in the background if they run the `unlock_query`. This price is assumed to be in the currency/unit defined in the `unlock_balance` datablock. |
| `unlock_query`              | `fixed_query` | only if `unlocked=False` | Query to perform to make the purchase.                                                                                                                                                         |
| `unlock_query_fallback_uri` | string        | no                       | An optional URI that the client MAY instead open in the user's web browser in order to let them make the purchase manually.                                                                    |











# 9. Implementation analysis and handling

## 9.1. Overview

This specification generally does not focus heavily on the exact handling of assets implementations and their associated files on the client side, as it may vary greatly between different applications/clients.
It only outlines a general structure that the client SHOULD follow in order to make its asset definitions as portable between applications as reasonably possible.

When receiving several implementations for the same asset from a provider, the client SHOULD, broadly, perform the following steps:

1. Analyze the implementations and decide if there is one (or multiple) that it can handle.
2. If multiple implementations are deemed acceptable, choose one to *actually* import.
3. Run the import, which entails:
   1. Dedicate a space in its local storage to the asset (this is almost certainly a directory but could theoretically also be another means of storage in a proprietary database system).
   2. Performing any required unlocking queries using the information in the `unlock_queries`, `file_fetch.download_post_unlock` and other datablocks.
   3. Fetch all files for all components using the instructions in their `file_fetch.*` datablocks.
   4. Handle the component files using the instructions in the `file_handle`, `format.*` and other datablocks.

Client implementors SHOULD consider whether these steps are fitting to their environment and make deviations, if necessary.
The client MAY choose create an intermediary plan to allow the user to preview the import process (steps taken, files downloaded, etc.) before it is performed.

## 9.2. Implementation analysis

When analyzing a set of implementation sent from the provider via the [implementation list endpoint](#54-implementation-list),
the client SHOULD decide for every implementation whether it is "readable".
It MAY represent this as a binary choice or a more gradual representation.

Possible factors for this decision are:

- The file types used in the implementation, as indicated by the `extension` field in the `file_handle` datablock.
- The use of more advanced AssetFetch features such as archive handling or asset unlocking.
- Format-specific indicators in the `format.*` datablock which indicate that the given file is incompatible with the client/host application. 

## 9.3. Implementation import

If at least one of the implementations offered by the provider has been deemed readable, the client can proceed and make an actual import attempt.
This usually involves interaction with the host application which means that client implementors SHOULD consider the steps outlined in this section only as a rough indicator for how to perform the import.

### 9.3.1. The implementation directory

For handling the implementation of an asset offered by the provider the client SHOULD make a dedicated directory into which all the files described by all the components can be arranged.
For this purpose it MAY use the `id` values transmitted on the provider-, asset- and implementation queries.
The directory SHOULD be empty at the start of the component handling process.

### 9.3.2. Performing unlock queries

If the implementation contains components with a `file_fetch.download_post_unlock` datablock,
then the client MUST perform the unlock query referenced in that datablock before it can proceed.
Otherwise the resources may not be fully unlocked and the provider will likely refuse to hand over the files.

### 9.3.3. Handling component files

The behavior of a component is dictated by the value of the `behavior` field in the `file_handle` datablock.

#### 9.3.3.1. Handling for `single_active`

Fetch the file using the instructions in the `file_fetch.*` datablock and place it in the `local_path` listed in the `file_handle` datablock.
Next, make an attempt to load this file directly, for example through the host application's native import functionality.

#### 9.3.3.2. Handling for `single_passive`

Fetch the file using the instructions in the `file_fetch.*` datablock and place it in the `local_path` listed in the `file_handle` datablock.

The client SHOULD NOT make a direct attempt to load this file and only process it in the case that it is referenced by another (active) component.
This can be either through a native reference in the component file itself (in which ase the host application's native import functionality will handle the references by itself)
or through a reference in the AssetFetch data (like the `loose_material.apply` datablock), in which case the client needs to take additional action to handle the file.

#### 9.3.3.3. Handling for `archive_unpack_fully`

Fetch the file using the instructions in the `file_fetch.*` datablock and place it in a temporary location.

The client MUST unpack the full contents of the archive root into the implementation directory using the `local_path` in the `file_handle` datablock as the sub-path inside the implementation directory.

#### 9.3.3.4. Handling for `archive_unpack_referenced`

Fetch the file using the instructions in the `file_fetch.*` datablock and place it in a temporary location.

Then unpack only those files that are referenced by other components in their `file_fetch.from_archive` datablocks.
Use the `local_path` in the individual component's `file_handle` datablock as the unpacking destination.

#### 9.3.3.5. Collisions in the implementation directory

In general, if an implementation assigns the same `local_path` to two different components, then the client's behavior is undefined.
Providers MUST avoid configurations that lead to this outcome.

If the `local_path` of a component with behavior `single_*` overlaps with a file from within an archive with the behavior `archive_unpack_fully`, then the first (single)
component SHOULD take priority and overwrite the file from within the archive.
Therefore, the client SHOULD perform all unpacking initiated by archive components with the `archive_unpack_fully` value first, and then start handling the remaining components for individual files.

Conflicts as the result of two archive components with `archive_unpack_fully` behavior have undefined behavior and MUST be avoided by the provider.

## 9.4. Local Storage of Asset Files
As described in the previous section, individual asset components/files may have implicit relationships to each other that are not directly visible from any of the datablocks such as relative file paths within project files.
To ensure that these references are still functional, AssetFetch specifies certain rules regarding how clients arrange downloaded files in the local file system.

A client SHOULD create a dedicated directory for every implementation of every asset that it downloads.
The location of this directory is not specified and can be fixed for all uses of the client. It can also be dependent on the context in which the client currently runs, for example a subfolder relative to the open project in a 3D suite.
Inside this directory it SHOULD place every file as specified in the `local_path` field of the component's `datablock`.
When opening any downloaded file it SHOULD happen from this directory to ensure that relative file paths continue to work.

## 9.5. Materials

Materials can be handled in several different ways, which are outlined in this section.

### 9.5.1. Using native formats and hidden components
Many file formats for 3D content - both vendor-specific as well as open - offer native support for referencing external texture files.
Providers SHOULD use these "native" material formats whenever possible.
When materials are used alongside a 3D model file with proper support, the material map components SHOULD be marked with the behavior `single_passive`,
since they will be referenced by the host application's native importer automatically.

#### 9.5.1.1. MTLX
The `mtlx_apply` datablock allows references from a component representing a mesh to a component representing an MaterialX (MTLX) file.
This allows the use of `.mtlx` files with mesh file formats that do not have the native ability to reference MTLX files.

### 9.5.2. Using loose material declarations
The workflow outlined in the previous sections is not always easily achievable since not all file 3D file formats offer up-to-date (or any) support for defining materials.
Provider may also have their own practical reasons for not offering their material definitions in a widely recognized machine-readable format.

In those cases it is currently common practice to simply distribute the necessary material maps along with the mesh files without any concrete machine-readable description for how the maps should be applied.

The `loose_material.*` datablocks exist to limit the negative impacts of this limitation.
They make it possible to define basic PBR materials through datablocks on the individual map components and reference them on the mesh component.

Providers SHOULD make use of this notation if, and only if, other more native representations of the material are unavailable of severely insufficient.

## 9.6. Environments
HDRI environments or skyboxes face a similar situation as materials:
They can be represented using native formats, but a common practice is to provide them as a singular image file whose projection must be manually inferred by the artist.
The `loose_environment` datablock works similar to the `loose_material.*` datablocks and allows the provider to communicate that a component should be treated as an environment and what projection should be used.









# 10. Security Considerations

This section describes security considerations for implementing AssetFetch.

## 10.1. Storing sensitive headers
During the initialization step providers can mark headers as sensitive.
Clients MUST find an appropriate solution for storing these sensitive headers.
They SHOULD consider storing secret headers through native operation system APIs for credential management.

## 10.2. Avoiding Relative Paths in `local_path`
Datablocks of the `fetch.*` family specify a local sub-path for every component that needs to be appended to a local path chosen by the client in order to assemble the correct file structure for this asset.
As specified in the [datablock requirements](#83-file-related-datablocks) the `local_path` MUST NOT contain relative references, especially back-references (`..`) as they can allow the provider to place files anywhere on the user's system ( Using a path like`"local_path":"../../../../example.txt"`).
Clients MUST take cate to ensure that components with references like `./` or `../` in their local path are rejected.