# BTLC_Toolkit
# About
3dsmax Toolkit for BTLC project. Allows nearly automatic conversion of IV map to GTA SA. 

# Features

## Implemented
- Model conversion.
   - prelight by using iv shaders
   - prelight using 2dfx lights (radiosity)
   - material sorting for rendering order (alpha materials)
   - Material / Model renaming for gta sa. (Long names cutting)

- Collision generation
   - Automatic Collisionmesh generation
   - auto Collision material assignment
   - Auto Mesh optimization
   - Auto Batch export to .col archive

- Texture conversion
   - auto long name cutting 
   - generate txd from folders

- Data Converter
   - Convert Ide & Placement data.

- Img Builder
   - directly build img from folder

- Toolchain
   - combines above functions into a automatic tool.

## W.I.P.
- 2dfx export to model
- Breakable export to model
- Toolchain models conversion without city part.
- Collision Generator for dynamic objects 

## Planned
- Path Toaolkit
- Animation Toolkit
- UV Animation converter


# background info

This toolchain is a combination of max scripts and external tool. 

## Model conversion
The model conversion mostly works by using the openformats models and imports them with an modified ofio script. 

Here the materials get directly set as RW material with env and opacity maps supported. Afterwards the materials get resorted to always have alpha textures on the highest material id. This assures that this material is rendered last. (Would cause alpha bugs otherwise). 
At import the prelight gets also modified. The vertex paint is made 30% darker to have better visual rendering in gta sa. For night the prelight is made 90% darker. By looking at the iv shader names materials which have "emissive" shader are painted white at night. 
Additionally a radiosity vertex paint can be used for nice night prelight which generates lightning using the 2dfx lights in the models. This is applied on to the already existing night prelight with screen blend mode.

Export works by using the rw importer/exporter by aap. This exports the models to .dff.


## Collisions
For collision a highly modified version of the collision plugin by cj2000 is used.

For every model object a copy is generated which represents the collision mesh. A script applies the correct collision materials by searching for keywords in the material names. (E.g. "metal").
Afterwards a optimizer modifier and an optimization script are applied to reduce complexity and avoid collision bugs.

A script exports all collisions in the scene directly to a .col archive. Currently it has to be opened once in colleditor2 to generate face groups!!

## Texture Conversion
This is  a toolchain to gather textures, cut names and build txd files. Most times these functions are embedded in different tools.
For example the textures of models are copied and cut when we convert an IV ide to an SA one.
Another tool cuts all texture names in a given folder(with child folders).
These texture folders are build to texture archives with the txdbuilder program.


## Data Conversion
IDE data is converted very simple. The iv ide and a startid is given. The ids are given in increasing order. Additionally name cutting and some flags are set l. (E.g. the flag for roads is set if the name has "road" in it)

The placement conversion is little bit more complicated. The placement converter gets the opl files from iv, the converted ide and a list of objects. This objectlist is exported from 3dsmax scene. Basicly first we import the city part in 3dsmax and then export the used objs(user wont see this happening/ doesn't need to know).
With this data the placement searches for all instances of the objects and writes that into new placement files. It will also search for lod instances of these models. This approach gets rid of the lods of detail objects. This helps keeping the id count low. (SA has an ud limit only broken by the very bad fla)
It also copys and cuts all textures


## Credits:
- Uses a modified version of ofio.
- collision export plugin by cj2000
- img builder by silent
- renderware exporter/importer by aap



