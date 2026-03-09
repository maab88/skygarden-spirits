# Skygarden Spirits - AGENTS.md

## Project Summary
This is a beginner-friendly 2D mobile puzzle game built in Godot 4 using GDScript.
The game is grid-based and uses weather powers to change tile states and satisfy level goals.

## Priorities
- Keep the code simple and readable.
- Favor maintainability over clever abstractions.
- Make changes incrementally.
- Do not rewrite working systems unless explicitly asked.
- Keep gameplay logic separate from UI logic.
- Prefer deterministic gameplay logic.
- Use data-driven level definitions from JSON.
- Mobile-first design: touch-friendly buttons, readable UI, low complexity.

## MVP Scope
Only implement:
- title screen
- level select
- gameplay scene
- results screen
- local save
- 10 handcrafted levels
- 4 powers: Rain, Sun, Wind, Frost
- tile types: Empty, CropDry, CropGrowing, CropHarvested, Fire, Water, Rock, Ice
- win conditions: HarvestAllCrops, RemoveAllFire
- lose condition: OutOfMoves

Do not add:
- ads
- in-app purchases
- backend
- live events
- online features
- analytics SDKs
- cloud save
- account systems

## Code Style
- Use clear names.
- Keep scripts focused.
- Avoid giant scripts.
- Add comments only where logic is non-obvious.
- Prefer small helper functions.
- Avoid introducing third-party plugins unless explicitly asked.

## Output Expectations
When implementing a feature:
- explain what files were created/changed
- explain how to test it manually
- note any inspector or scene hookups required

Important constraints:
- Do not rename existing files.
- Do not change project settings.
- Do not generate placeholder gameplay systems.
- Only do the folder creation and AGENTS.md creation requested above.