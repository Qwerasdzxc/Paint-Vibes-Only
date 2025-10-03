# Tasks: Paint Vibes Only - Creative Drawing App

**Input**: Design documents from `/specs/001-paint-vibes-only/`
**Prerequisites**: plan.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓, quickstart.md ✓

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → FOUND: Flutter 3.13+, mobile app, CustomPainter architecture
   → Extracted: Dart/Flutter tech stack, local file storage
2. Load optional design documents:
   → data-model.md: 8 entities → 8 model tasks [P]
   → contracts/: 7 service interfaces → 7 contract test tasks [P]
   → quickstart.md: 5 integration scenarios → 5 integration tests [P]
3. Generate tasks by category:
   → Setup: Flutter project, dependencies, linting
   → Tests: contract tests, widget tests, integration tests  
   → Core: models, services, widgets, screens
   → Integration: storage, navigation, state management
   → Polish: unit tests, performance, documentation
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness: ✓ All contracts have tests, ✓ All entities have models
9. Return: SUCCESS (42 tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Flutter project**: `lib/`, `test/`, `integration_test/` at repository root
- Feature-based organization: `lib/features/drawing/`, `lib/features/coloring/`, etc.
- Shared utilities: `lib/shared/`, `lib/core/`

## Phase 3.1: Setup
- [X] T001 Create Flutter project structure with feature-based organization (lib/features/, lib/shared/, lib/core/)
- [X] T002 Initialize pubspec.yaml with Flutter 3.13+ dependencies: path_provider, share_plus, image, flutter_colorpicker
- [X] T003 [P] Configure analysis_options.yaml with Flutter linting rules and custom lint rules
- [X] T004 [P] Set up build configuration for iOS (ios/Runner.xcworkspace, Info.plist permissions)
- [X] T005 [P] Set up build configuration for Android (android/app/build.gradle, AndroidManifest.xml permissions)

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

### Contract Tests [P] - Service Interface Compliance
- [X] T006 [P] Contract test IDrawingService interface in test/contract/test_drawing_service_contract.dart
- [X] T007 [P] Contract test IColorService interface in test/contract/test_color_service_contract.dart
- [ ] T008 [P] Contract test IArtworkService interface in test/contract/test_artwork_service_contract.dart
- [ ] T009 [P] Contract test IColoringService interface in test/contract/test_coloring_service_contract.dart
- [ ] T010 [P] Contract test IFileService interface in test/contract/test_file_service_contract.dart
- [ ] T011 [P] Contract test ISettingsService interface in test/contract/test_settings_service_contract.dart
- [ ] T012 [P] Contract test IEventService interface in test/contract/test_event_service_contract.dart

### Widget Tests [P] - Core UI Components
- [ ] T013 [P] Widget test DrawingCanvas widget in test/widget/test_drawing_canvas_widget.dart
- [ ] T014 [P] Widget test ColorPicker widget in test/widget/test_color_picker_widget.dart
- [ ] T015 [P] Widget test ToolSelector widget in test/widget/test_tool_selector_widget.dart
- [ ] T016 [P] Widget test GalleryGrid widget in test/widget/test_gallery_grid_widget.dart
- [ ] T017 [P] Widget test ColoringPageWidget in test/widget/test_coloring_page_widget.dart

### Integration Tests [P] - User Scenarios
- [ ] T018 [P] Integration test drawing workflow in integration_test/test_drawing_workflow.dart
- [ ] T019 [P] Integration test color selection workflow in integration_test/test_color_workflow.dart
- [ ] T020 [P] Integration test undo/redo operations in integration_test/test_undo_redo_workflow.dart
- [ ] T021 [P] Integration test save/load artwork in integration_test/test_save_load_workflow.dart
- [ ] T022 [P] Integration test coloring mode workflow in integration_test/test_coloring_workflow.dart

## Phase 3.3: Core Implementation (ONLY after tests are failing)

### Data Models [P] - Entity Classes
- [X] T023 [P] DrawingCanvas model in lib/shared/models/drawing_canvas.dart
- [X] T024 [P] DrawingStroke model in lib/shared/models/drawing_stroke.dart
- [X] T025 [P] DrawingTool model in lib/shared/models/drawing_tool.dart
- [X] T026 [P] Artwork model in lib/shared/models/artwork.dart
- [ ] T027 [P] ColoringPage model in lib/shared/models/coloring_page.dart
- [ ] T028 [P] ColoringProgress model in lib/shared/models/coloring_progress.dart
- [X] T029 [P] ColorPalette model in lib/shared/models/color_palette.dart
- [ ] T030 [P] UserGallery model in lib/shared/models/user_gallery.dart

### Service Implementations - Core Business Logic
- [X] T031 DrawingService implementation in lib/features/drawing/services/drawing_service.dart
- [X] T032 ColorService implementation in lib/features/drawing/services/color_service.dart
- [ ] T033 ArtworkService implementation in lib/features/gallery/services/artwork_service.dart
- [ ] T034 ColoringService implementation in lib/features/coloring/services/coloring_service.dart
- [ ] T035 FileService implementation in lib/core/storage/file_service.dart
- [ ] T036 SettingsService implementation in lib/core/services/settings_service.dart
- [ ] T037 EventService implementation in lib/core/services/event_service.dart

### UI Widgets - Drawing Components
- [ ] T038 DrawingCanvas CustomPainter widget in lib/features/drawing/widgets/drawing_canvas.dart
- [ ] T039 ColorPicker widget with HSV support in lib/features/drawing/widgets/color_picker.dart
- [ ] T040 ToolSelector widget with tool icons in lib/features/drawing/widgets/tool_selector.dart
- [ ] T041 UndoRedoControls widget in lib/features/drawing/widgets/undo_redo_controls.dart

### Screens - Main UI Pages
- [X] T042 DrawingScreen main interface in lib/features/drawing/screens/drawing_screen.dart
- [X] T043 ColoringScreen interface in lib/features/coloring/screens/coloring_screen.dart
- [X] T044 GalleryScreen with artwork grid in lib/features/gallery/screens/gallery_screen.dart
- [X] T045 HomeScreen navigation hub in lib/features/home/screens/home_screen.dart

## Phase 3.4: Integration
- [X] T046 File system storage integration with path_provider in lib/core/storage/file_storage_manager.dart
- [X] T047 State management setup with Provider in lib/core/providers/app_providers.dart
- [X] T048 Navigation routing configuration in lib/core/navigation/app_routes.dart
- [X] T049 Dependency injection setup in lib/core/dependency_injection/service_locator.dart
- [X] T050 Error handling and logging system in lib/core/utils/error_handler.dart

## Phase 3.5: Polish
- [ ] T051 [P] Unit tests for drawing algorithms in test/unit/test_drawing_algorithms.dart
- [ ] T052 [P] Unit tests for color conversions in test/unit/test_color_conversions.dart
- [ ] T053 [P] Unit tests for file operations in test/unit/test_file_operations.dart
- [ ] T054 [P] Performance tests for drawing latency (<50ms) in test/performance/test_drawing_performance.dart
- [ ] T055 [P] Golden tests for UI consistency in test/golden/test_ui_golden.dart
- [ ] T056 [P] Update README.md with setup and usage instructions
- [ ] T057 [P] Add inline code documentation and dartdoc comments
- [ ] T058 Final integration testing and manual validation

## Dependencies

### Critical Path Dependencies
```
Setup (T001-T005) → Tests (T006-T022) → Models (T023-T030) → Services (T031-T037) → Widgets (T038-T041) → Screens (T042-T045) → Integration (T046-T050) → Polish (T051-T058)
```

### Specific Dependencies
- **T006-T012**: Block T031-T037 (contract tests before service implementation)
- **T023-T030**: Block T031-T037 (models before services that use them)
- **T031-T037**: Block T038-T045 (services before UI that depends on them)
- **T038-T041**: Block T042-T045 (widgets before screens that use them)
- **T013-T017**: Block T042-T045 (widget tests before screen implementation)
- **T046-T050**: Required for T051-T058 (integration before final polish)

### Parallel Execution Opportunities
- **Models (T023-T030)**: All parallel - different files, no dependencies
- **Contract Tests (T006-T012)**: All parallel - different test files
- **Widget Tests (T013-T017)**: All parallel - different test files
- **Integration Tests (T018-T022)**: All parallel - different test files
- **Polish Tasks (T051-T058)**: Most parallel except T058

## Parallel Example - Contract Tests
```bash
# Launch T006-T012 together:
Task: "Contract test IDrawingService interface in test/contract/test_drawing_service_contract.dart"
Task: "Contract test IColorService interface in test/contract/test_color_service_contract.dart"
Task: "Contract test IArtworkService interface in test/contract/test_artwork_service_contract.dart"
Task: "Contract test IColoringService interface in test/contract/test_coloring_service_contract.dart"
Task: "Contract test IFileService interface in test/contract/test_file_service_contract.dart"
Task: "Contract test ISettingsService interface in test/contract/test_settings_service_contract.dart"
Task: "Contract test IEventService interface in test/contract/test_event_service_contract.dart"
```

## Parallel Example - Data Models
```bash
# Launch T023-T030 together:
Task: "DrawingCanvas model in lib/shared/models/drawing_canvas.dart"
Task: "DrawingStroke model in lib/shared/models/drawing_stroke.dart"
Task: "DrawingTool model in lib/shared/models/drawing_tool.dart"
Task: "Artwork model in lib/shared/models/artwork.dart"
Task: "ColoringPage model in lib/shared/models/coloring_page.dart"
Task: "ColoringProgress model in lib/shared/models/coloring_progress.dart"
Task: "ColorPalette model in lib/shared/models/color_palette.dart"
Task: "UserGallery model in lib/shared/models/user_gallery.dart"
```

## Flutter-Specific Implementation Notes

### CustomPainter Implementation (T038)
```dart
// Key requirements for DrawingCanvas CustomPainter:
class DrawingCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Implement multi-layer rendering
    // Background → Strokes → UI overlay
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Optimize repaints based on canvas state
    return true; // Implement smart repaint logic
  }
}
```

### State Management Pattern (T047)
```dart
// Use Provider for state management
MultiProvider(
  providers: [
    ChangeNotifierProvider<DrawingState>(create: (_) => DrawingState()),
    ChangeNotifierProvider<ColorState>(create: (_) => ColorState()),
    ChangeNotifierProvider<GalleryState>(create: (_) => GalleryState()),
  ],
  child: PainterApp(),
)
```

### Performance Considerations
- **Drawing latency**: Target <50ms from touch to stroke appearance
- **Memory management**: Limit stroke history to prevent memory issues  
- **File I/O**: Async operations for save/load to avoid UI blocking
- **Image optimization**: Compress thumbnails for gallery performance

## Validation Checklist
*GATE: Checked before task completion*

- [x] All 7 service contracts have corresponding contract tests (T006-T012)
- [x] All 8 entities have model creation tasks (T023-T030) 
- [x] All tests come before implementation (T006-T022 before T031+)
- [x] Parallel tasks are truly independent (different files, no shared state)
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
- [x] Flutter project structure follows feature-based organization
- [x] TDD workflow enforced (tests must fail before implementation)

## Testing Strategy

### Test Coverage Goals
- **Unit Tests**: >90% coverage for business logic
- **Widget Tests**: All custom widgets and screens
- **Integration Tests**: Complete user workflows
- **Golden Tests**: UI consistency across Flutter versions
- **Performance Tests**: Drawing latency and memory usage

### Key Test Scenarios
1. **Drawing Workflow**: Touch input → stroke creation → canvas update
2. **Color Selection**: Palette interaction → color change → stroke color update  
3. **Undo/Redo**: Action history → state restoration → UI update
4. **Save/Load**: Canvas serialization → file storage → deserialization
5. **Coloring Mode**: Page selection → progress tracking → completion detection

## Success Metrics
- All 58 tasks completed successfully
- 100% contract test compliance
- <50ms drawing latency achieved
- All integration tests passing
- App successfully builds and runs on Web
- Manual validation scenarios complete

This comprehensive task list provides 58 actionable, dependency-ordered tasks for implementing the Paint Vibes Only creative drawing app, following TDD principles and Flutter best practices.