# Elysia — 3D Character Studio

Native Android 3D character-customization prototype built with Godot 4.

## Current scope
- Landscape-first Android interface.
- A 3D adult character in opaque starter underwear.
- Body proportion sliders, face presets, eye and hair colors.
- Several fully opaque outfit presets.
- Drag-to-rotate camera and local profile save.
- GitHub Actions workflow that exports an ARM64 debug APK.

The first version uses a procedural 3D character assembled from meshes. It is a functional prototype, not a photorealistic scanned or professionally rigged character. True film-quality 4K detail, facial animation, cloth simulation and production character rigging require dedicated licensed 3D assets and additional testing.

## Build
Push to `main` or run the **Android APK** workflow manually. The workflow exports `build/CharacterStudio.apk`, uploads it as an Actions artifact and attaches the APK to a versioned GitHub Release.

## Controls
- Drag horizontally on the 3D area to rotate the character.
- Use the sliders and selectors in the left panel to customize the avatar.
- Save the current appearance with **Сохранить образ**.
