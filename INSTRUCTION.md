# Project Master Instruction: Purrfect Home

## 1. Project Identity

**Project Name:** Purrfect Home    
**Project Type:** Mobile Game Development  
**Team Size:** 2  
**Framework:** Flutter  
**Game Engine:** Flame  
**Language:** Dart

### Project Description

Purrfect Home is a cozy cat life simulation and room decoration mobile game. The player takes care of a virtual cat, earns coins, purchases furniture and supplies, and gradually builds a comfortable home.

The game combines virtual pet care, room decoration, resource management, autonomous cat behavior, and progression. It should provide a relaxing experience rather than a competitive or stressful one.

The visual direction is cute, minimal, cozy, and cartoon-like, with a fixed 2.5D isometric-style room.

---

## 2. Core Game Design

### 2.1 Gameplay Loop

The main gameplay loop should follow this process:

1. The player enters their home and observes their cat.
2. The player checks the cat's needs.
3. The player interacts with the cat by feeding, petting, or playing.
4. The player collects available coins and completes tasks.
5. The player visits the shop to purchase items.
6. The player places or rearranges furniture in the room.
7. The cat autonomously interacts with suitable furniture.
8. The player progresses toward expanding and improving their home.
9. The game saves progress, allowing the player to continue later.

The gameplay loop should be simple, repeatable, and enjoyable.

### 2.2 Cat System

The game will initially contain one cat.

The cat has the following status values:

- Hunger: represents how hungry the cat is.
- Energy: represents how tired the cat is.
- Happiness: represents the cat's overall mood.
- Affection: represents long-term relationship progression with the player.

Hunger, Energy, and Happiness are short-term values.

Affection is a long-term progression value that increases through positive interactions.

All status values should have defined minimum and maximum values. Use a consistent scale, such as 0–100.

The cat should be able to:

- Walk around the room.
- Sit and rest.
- Sleep.
- Play.
- Scratch suitable furniture.
- Sit near a window or designated furniture.
- React to player interactions.
- Choose activities based on its needs and available objects.

The cat should not require the player to control every movement.

### 2.3 Cat Behavior

The cat should behave autonomously using a simple state-based behavior system.

Suggested states:

- Idle
- Walking
- Sleeping
- Sitting
- Playing
- Eating
- Scratching

The behavior system should consider:

- Current needs.
- Available furniture.
- Whether the cat is already performing an activity.
- Whether a target location is reachable.

For the initial implementation, use simple behavior rules instead of complex AI.

Example:

- If Energy is low, the cat prefers a bed.
- If Hunger is low, the cat can seek food when available.
- If a toy is available and the cat is in a playful state, it can interact with it.
- Otherwise, the cat can walk around or choose an idle behavior.

Avoid unnecessary AI, machine learning, or external API integrations.

### 2.4 Time Progression

Use a hybrid time progression system.

**Offline progression:**

- Coins accumulate while the game is closed.
- Offline income has a configurable maximum accumulation duration.
- The player collects or receives the accumulated income when returning.
- Offline progression should not create excessive rewards.

**Active gameplay progression:**

- Cat needs and activities mainly progress while the game is being played.
- Cat interactions affect the needs and affection values.
- Active progression should be configurable and balanced.

Avoid making the player feel punished for not opening the game.

### 2.5 Economy System

The game has one main currency: Coins.

Coins can be earned through:

- Passive income.
- Completing tasks.
- Future optional gameplay activities.

Coins can be spent on:

- Food.
- Toys.
- Beds.
- Scratching posts.
- Decorations.
- Furniture.
- Room improvements.

The economy must be configurable.

Avoid hardcoding coin prices and rewards inside UI widgets or unrelated game components.

### 2.6 Room System

The game starts with one small room.

The player gradually unlocks additional space within the same room.

The room should use a fixed isometric-style perspective.

For the initial implementation:

- Use a simple room with a visible floor.
- Use a grid-based furniture placement system.
- Furniture must snap to the grid.
- Furniture should not overlap incorrectly.
- Furniture should be movable after placement.
- Furniture should support rotation if practical.
- Furniture should have defined dimensions.
- Cat movement should respect obstacles and furniture where practical.

Do not build multiple rooms for the initial version.

### 2.7 Furniture and Interactions

Furniture should have gameplay meaning.

Examples:

- Cat bed: allows the cat to sleep and recover Energy.
- Food bowl: supports feeding.
- Scratching post: supports scratching behavior.
- Toy: supports play behavior and Happiness.
- Window perch: supports sitting or resting.
- Decorative furniture: improves the appearance of the room.

Furniture should be represented by reusable data-driven definitions rather than individually hardcoded gameplay logic.

### 2.8 Screens

The game should have the following primary screens:

1. Home / Room
2. Shop
3. Tasks
4. Cat Profile

The Home / Room screen is the main gameplay screen.

Flutter should handle the general UI, menus, navigation, and panels. Flame should handle the interactive game world.

---

## 3. Technology Stack

Use the following technologies.

### Flutter

Responsible for:

- Application structure.
- Navigation.
- Main screens.
- Shop UI.
- Task UI.
- Cat profile.
- HUD and status displays.
- Dialogs and overlays.
- Settings and menus.

### Flame

Responsible for:

- Game scene rendering.
- Game loop.
- Sprite rendering.
- Cat animation.
- Game world interactions.
- Room rendering.
- Furniture rendering.
- Game-world movement and interactions.

### Dart

Responsible for:

- Game logic.
- Cat state.
- Cat behavior.
- Economy.
- Tasks.
- Room logic.
- Inventory.
- Data models.
- Application services.

### Local Persistence

Choose an appropriate local storage solution, such as SharedPreferences or Hive.

The persistence system must save:

- Coins.
- Cat status.
- Affection.
- Inventory.
- Purchased items.
- Furniture placement.
- Room progression.
- Task progress, if applicable.
- Last saved time or last active timestamp.
- Relevant game settings.

Choose one storage solution based on the project's requirements. Do not introduce multiple storage solutions without a strong reason.

### Assets

Initially, use placeholder assets or simple generated visual assets when necessary.

Organize assets into a consistent structure.

The project should eventually use sprite sheets for cat animations and suitable images for furniture and other game objects.

Do not block core development on obtaining final art assets.

Do not use copyrighted game assets without permission.

---

## 4. Architecture and Code Organization

Build a clean, modular, and maintainable Flutter project.

Use a feature-oriented architecture with separation between:

- UI.
- Game rendering.
- Gameplay logic.
- Models.
- Services.
- Persistence.
- Configuration.
- Shared components.

Suggested directory structure:

lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── game_constants.dart
│   │   └── asset_paths.dart
│   ├── config/
│   │   └── game_config.dart
│   ├── utils/
│   │   └── ...
│   └── widgets/
│       └── ...
│
├── features/
│   ├── game/
│   │   ├── game_screen.dart
│   │   ├── game_controller.dart
│   │   ├── world/
│   │   │   ├── home_world.dart
│   │   │   └── room_world.dart
│   │   ├── components/
│   │   │   ├── cat_component.dart
│   │   │   ├── furniture_component.dart
│   │   │   └── ...
│   │   ├── systems/
│   │   │   ├── cat_behavior_system.dart
│   │   │   ├── movement_system.dart
│   │   │   └── ...
│   │   └── overlays/
│   │       └── ...
│   │
│   ├── cat/
│   │   ├── models/
│   │   │   └── cat_state.dart
│   │   ├── services/
│   │   │   └── cat_service.dart
│   │   └── widgets/
│   │       └── ...
│   │
│   ├── economy/
│   │   ├── models/
│   │   │   └── ...
│   │   └── services/
│   │       └── economy_service.dart
│   │
│   ├── shop/
│   │   ├── models/
│   │   │   └── shop_item.dart
│   │   ├── screens/
│   │   │   └── shop_screen.dart
│   │   └── services/
│   │       └── shop_service.dart
│   │
│   ├── inventory/
│   │   ├── models/
│   │   │   └── ...
│   │   └── services/
│   │       └── inventory_service.dart
│   │
│   ├── room/
│   │   ├── models/
│   │   │   ├── furniture_data.dart
│   │   │   └── placement_data.dart
│   │   ├── services/
│   │   │   └── room_service.dart
│   │   └── ...
│   │
│   ├── tasks/
│   │   ├── models/
│   │   │   └── ...
│   │   ├── screens/
│   │   │   └── tasks_screen.dart
│   │   └── services/
│   │       └── task_service.dart
│   │
│   ├── cat_profile/
│   │   └── ...
│   │
│   └── settings/
│       └── ...
│
├── data/
│   ├── repositories/
│   │   └── game_repository.dart
│   ├── storage/
│   │   └── local_storage_service.dart
│   └── ...
│
└── shared/
    ├── models/
    ├── widgets/
    └── ...

This structure is a starting point, not a requirement to create every folder immediately.

Only create files when they are needed.

The architecture may be adjusted if a better solution is justified, but maintain clear separation of concerns.

---

## 5. Coding Rules

Follow these coding principles throughout development:

1. Write clean, readable, and modular Dart code.
2. Keep files focused on one responsibility.
3. Avoid excessively large widgets, components, or service classes.
4. Avoid tightly coupling Flutter UI to game logic.
5. Avoid tightly coupling Flame components to persistence.
6. Use reusable components where appropriate.
7. Use models for structured game data.
8. Keep game values, prices, rewards, and timing configurable.
9. Avoid unnecessary global state.
10. Avoid duplicating gameplay logic.
11. Use clear naming conventions.
12. Handle errors and edge cases.
13. Dispose of controllers, listeners, and resources when necessary.
14. Avoid unnecessary packages and dependencies.
15. Keep the code beginner-friendly enough for a university project team to understand and maintain.
16. Do not implement overly complex design patterns without justification.
17. Do not add backend services unless the project requirements change.
18. Do not implement features beyond the agreed scope without discussing them first.

### State Management

Use an appropriate state management approach for Flutter UI and game-related state.

Choose a simple and maintainable solution suitable for a two-person university project.

Keep game state separate from widget state when the state represents persistent or shared gameplay information.

Do not introduce a complicated state management architecture unless the project genuinely requires it.

---

## 6. Development Workflow

Development must be divided into stages.

Do not attempt to implement the entire game in one step.

At each stage:

1. Inspect the existing project and files.
2. Understand the current implementation.
3. Identify what the current stage requires.
4. Propose the implementation approach.
5. Implement only the agreed stage.
6. Run Flutter analysis and appropriate tests.
7. Fix issues introduced by the implementation.
8. Summarize the changes.
9. Explain how to run and verify the result.
10. Identify the next stage.

Do not overwrite existing working code unnecessarily.

If the project already contains code, preserve and improve it rather than rebuilding blindly.

Do not assume the project is empty.

---

## 7. Development Roadmap

### Phase 1: Project Foundation

Goal: Build the initial playable room foundation.

Implement:

- Flutter project setup.
- Flame integration.
- Main application structure.
- Home / Room screen.
- Fixed camera or fixed viewport.
- Basic isometric-style floor.
- Grid system.
- Basic room rendering.
- Placeholder cat sprite.
- Basic cat animation or movement.
- Flutter-to-Flame integration.

Deliverable:

A mobile application that opens into a basic room scene containing a cat.

The cat and room must render correctly on the target mobile screen.

Do not implement the full shop, economy, tasks, or room expansion in this phase.

### Phase 2: Cat Gameplay

Goal: Implement the basic virtual pet system.

Implement:

- Hunger.
- Energy.
- Happiness.
- Affection.
- Feeding interaction.
- Petting interaction.
- Playing interaction.
- Basic autonomous cat behavior.
- State-based cat activities.
- Basic movement and interaction logic.

Deliverable:

A cat that can move, perform basic activities, and respond to player interactions with meaningful changes to its status.

### Phase 3: Economy and Time

Goal: Implement game progression and rewards.

Implement:

- Coin system.
- Passive income.
- Offline income calculation.
- Offline income cap.
- Task reward integration where appropriate.
- Configurable economy values.
- Basic reward UI.

Deliverable:

Players can earn and spend coins, and receive capped offline income when returning to the game.

### Phase 4: Furniture and Room Interaction

Goal: Implement the room customization system.

Implement:

- Furniture data models.
- Furniture rendering.
- Grid-based placement.
- Placement validation.
- Furniture movement.
- Furniture selection.
- Rotation if practical.
- Inventory integration.
- Cat interaction with appropriate furniture.

Deliverable:

Players can place and rearrange furniture in the room, and the cat can interact with selected furniture types.

### Phase 5: Shop and Inventory

Goal: Allow players to acquire and manage items.

Implement:

- Shop screen.
- Item categories.
- Item prices.
- Purchasing logic.
- Inventory.
- Purchase validation.
- Item availability.

Deliverable:

Players can purchase items with coins and use purchased furniture or supplies.

### Phase 6: Tasks and Room Progression

Goal: Introduce longer-term progression.

Implement:

- Simple task system.
- Task completion tracking.
- Task rewards.
- Room expansion.
- Unlockable space.
- Progression requirements.

Deliverable:

Players can complete objectives and gradually expand their room.

### Phase 7: Persistence

Goal: Ensure game progress survives application restarts.

Implement:

- Local save system.
- Loading saved progress.
- Saving cat status.
- Saving coins.
- Saving inventory.
- Saving furniture placements.
- Saving room progression.
- Saving relevant timestamps.
- Save data validation.
- Handling missing or corrupted data gracefully.

Deliverable:

Players can close and reopen the application without losing their main progress.

If a simple persistence foundation is needed earlier, implement it earlier rather than waiting until this phase.

### Phase 8: Polish and Testing

Goal: Make the game stable and presentable.

Implement or improve:

- UI polish.
- Animations.
- Interaction feedback.
- Sound effects if practical.
- Responsive layout.
- Performance.
- Error handling.
- Game balance.
- Testing.
- Final bug fixes.

Deliverable:

A stable, playable mobile game suitable for a university project demonstration.

---

## 8. Initial MVP Scope

Prioritize the following features for the first playable version:

- One cat.
- One small room.
- Fixed isometric-style perspective.
- Cat movement.
- Basic cat animations.
- Hunger, Energy, and Happiness.
- Affection progression.
- Feeding.
- Petting.
- Playing.
- A small furniture collection.
- Grid-based furniture placement.
- Basic coin economy.
- Capped offline income.
- Local progress saving.
- Basic shop.
- Simple tasks.

Additional features should only be added after the MVP is functional.

Possible future features:

- Additional cat appearances.
- More cat animations.
- More furniture.
- Additional room themes.
- Weather.
- Mini-games.
- More complex cat personalities.
- Additional interaction types.

These are optional and must not compromise the core game.

---

## 9. Testing Requirements

During development, verify the following:

### Application

- Application launches without errors.
- Screens display correctly.
- UI is responsive to different screen sizes.

### Cat

- Cat renders correctly.
- Cat movement works.
- Cat can change behaviors.
- Cat interactions affect needs correctly.
- Cat behavior does not become stuck unnecessarily.

### Economy

- Coins are added correctly.
- Coins cannot be spent beyond the available balance.
- Passive income calculation works.
- Offline income cap works.

### Furniture

- Furniture can be selected.
- Furniture can be placed.
- Furniture snaps to the grid.
- Invalid placement is prevented.
- Furniture can be moved after placement.

### Persistence

- Progress saves correctly.
- Progress loads correctly.
- Restarting the application does not reset progress.
- Offline income is calculated correctly.
- Invalid save data does not crash the application.

Use unit tests for important gameplay logic whenever practical.

---

## 10. Asset and Visual Guidelines

The game should have a cozy, cute, minimal, and cartoon-like style.

Preferred visual direction:

- Soft colors.
- Simple shapes.
- Cozy furniture.
- Cute cat design.
- Clear status indicators.
- Visually readable interactions.
- Isometric-style room.
- Consistent sprite style.

Use temporary assets during early development.

Do not delay the implementation of gameplay systems because of missing final artwork.

Keep all asset paths organized and centralized where appropriate.

---

## 11. Agent Responsibilities and Communication

Act as a development assistant and technical partner for this project.

Before implementing a stage:

- Inspect the project structure.
- Explain the planned changes briefly.
- Identify important architectural decisions.
- Identify potential risks.

During implementation:

- Follow the agreed architecture.
- Implement only the current stage.
- Avoid unnecessary refactoring.
- Keep changes focused.
- Do not silently change the game design.
- Do not create unnecessary files.
- Do not assume unimplemented features already exist.

After implementation:

- Provide a concise summary.
- List important files created or modified.
- Report tests and analysis results honestly.
- Explain any remaining problems.
- Provide the exact commands needed to run the application when relevant.

If a design decision is necessary:

- Prefer the simplest maintainable solution.
- Prefer solutions that are practical for a two-person university team.
- Explain trade-offs briefly.
- Ask only when the decision significantly affects architecture, scope, or gameplay.

Do not fabricate successful test results.

Do not report a feature as completed if it has not been implemented and verified.

---