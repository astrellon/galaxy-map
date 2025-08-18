# Galaxy Map

A small experiment in making something that looks like it could be pixel art in Godot 4.4

This is **just** an interactive map, it is not tied to a game in anyway. The goal of this project was just to play around with the visuals. I would not say that any of the techniques used here as being best practice or even particularly performant as the end goal was to take a video of the result.

![Screenshot](screenshot.png)

A hosted WebGL build should be found [here](https://alanlawrey.me/galaxy-map). It is definitely *NOT* optimised for mobile use.

Internally it's making use of a few different techniques:
- It runs at a native 480x270 resolution.
- Simple sprite sheets for animating stars.
- Vector graphics for the layers of the galaxy.
- 3D meshes for the wireframe scan lines of each object that can be clicked on.
- Raymarched SDFs for the final visual of each object.

The `sourceAssets` folder contains the Blender and Aseprite files that are used to create wireframe and textures.

## References
- SDF 3D functions by [Inigo Quilez](https://iquilezles.org/articles/distfunctions/)
- Additional SDF 3D functions by [Michael Fogleman](https://github.com/fogleman/sdf/blob/d58a6fc63b75fc1cf1ebb71e0b42bf552319c8f1/sdf/d3.py#L314)
- Black Hole shader by [z0rg](https://www.shadertoy.com/view/NdV3Rd)
- Raymarched Clouds by [Maxime Heckle](https://blog.maximeheckel.com/posts/real-time-cloudscapes-with-volumetric-raymarching/)
- Blur shader by [Juanito Pereyra](https://godotshaders.com/shader/gaussian-blur-2/)
- Outline shader by [Juulpower](https://godotshaders.com/shader/2d-outline-inline/)
- GLSL rotation functions by [Damien Seguin](https://github.com/dmnsgn/glsl-rotate)


## Author
Alan Lawrey 2025
