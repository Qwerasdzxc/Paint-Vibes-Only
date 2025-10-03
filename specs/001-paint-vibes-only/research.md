# Research: Paint Vibes Only - Creative Drawing App

**Phase 0**: Research & Technology Decisions  
**Date**: 25 September 2025

## Technical Research Summary

### Drawing Engine Architecture
**Decision**: Flutter CustomPainter with Canvas API  
**Rationale**: 
- Native performance for real-time drawing
- Complete control over rendering pipeline
- Supports complex shapes, gradients, and effects
- Built-in touch gesture recognition
- Cross-platform consistency

**Alternatives considered**:
- WebView with HTML5 Canvas: Rejected due to performance overhead and touch lag
- Native platform drawing (UIKit/Android Canvas): Rejected due to code duplication
- Third-party drawing libraries: Rejected to avoid external dependencies

### Storage Architecture
**Decision**: Local file system with hybrid storage approach  
**Rationale**:
- Drawing data: Binary PNG/JPG files for efficient storage and sharing
- Metadata: JSON files for artwork properties, coloring progress
- Uses path_provider for cross-platform directory access
- Offline-first approach eliminates network dependencies

**Alternatives considered**:
- SQLite database: Rejected due to binary data handling complexity
- Cloud storage only: Rejected due to offline requirement
- In-memory only: Rejected due to persistence requirements

### Color Management
**Decision**: HSV color space with RGB conversion  
**Rationale**:
- HSV provides intuitive color picker interface
- RGB for final rendering performance
- Supports both predefined and custom color workflows
- Efficient recent colors caching

**Alternatives considered**:
- RGB only: Rejected due to poor user experience in color picking
- LAB color space: Rejected due to complexity and mobile performance
- Built-in Flutter color picker: Rejected due to limited customization

### Drawing Tools Implementation
**Decision**: Strategy pattern with tool-specific renderers  
**Rationale**:
- Clean separation of tool behaviors
- Easy to extend with new tools
- Consistent undo/redo implementation
- Optimized rendering per tool type

**Tool Architecture**:
- Brush: Variable width paths with pressure simulation
- Pencil: Fixed width paths with texture
- Eraser: Blend mode manipulation
- Bucket: Flood fill algorithm
- Eyedropper: Pixel sampling
- Shapes: Geometric path generation

### Undo/Redo System
**Decision**: Command pattern with canvas snapshots  
**Rationale**:
- Efficient memory usage with differential storage
- Fast undo/redo operations
- Supports complex multi-stroke operations
- Configurable history depth

**Alternatives considered**:
- Full canvas snapshots: Rejected due to memory usage
- Vector-based history: Rejected due to complexity with raster operations
- Database-backed history: Rejected due to performance overhead

### Performance Optimizations
**Decision**: Multi-layered rendering with selective updates  
**Rationale**:
- Background layer: Static content (coloring page base)
- Drawing layer: Active user strokes
- UI layer: Tools, colors, interface elements
- Only redraw changed layers

**Key optimizations**:
- Canvas viewport clipping for large drawings
- Stroke simplification during fast drawing
- Async file I/O operations
- Memory pooling for frequently allocated objects

### Testing Strategy
**Decision**: Comprehensive test pyramid approach  
**Rationale**:
- Unit tests: Drawing algorithms, color conversion, file I/O
- Widget tests: Tool selection, color picker, canvas interaction
- Integration tests: Full user workflows, save/load operations
- Golden tests: Visual regression for drawing operations

## Dependencies Analysis

### Core Flutter Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  path_provider: ^2.1.1      # Cross-platform path access
  shared_preferences: ^2.2.2  # Settings and preferences
  image: ^4.1.3              # Image manipulation and export
  share_plus: ^7.2.1         # Native sharing functionality
  flutter_colorpicker: ^1.0.3 # Enhanced color selection
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mockito: ^5.4.2            # Mocking for unit tests
  golden_toolkit: ^0.15.0    # Golden file testing
```

## Architecture Decisions

### State Management
**Decision**: Provider + ChangeNotifier  
**Rationale**: 
- Suitable for medium complexity app
- Good performance for drawing operations
- Clear separation of concerns
- Efficient rebuilds for UI updates

### File Organization
**Decision**: Feature-based modular structure  
**Rationale**:
- Clear feature boundaries
- Easy to navigate and maintain
- Supports independent testing
- Scalable for future features

### Drawing Coordinate System
**Decision**: Logical coordinates with automatic scaling  
**Rationale**:
- Device-independent drawing data
- Consistent across different screen sizes
- Supports zoom and pan operations
- Efficient for coloring page alignment

### Coloring Page Format
**Decision**: SVG paths with PNG overlays  
**Rationale**:
- Vector-based outlines remain crisp at any size
- Raster coloring for performance
- Clear boundary detection for flood fill
- Efficient progress tracking

## Risk Mitigation

### Performance Risks
- **Risk**: Large drawing files causing memory issues
- **Mitigation**: Implement canvas tiling and lazy loading
- **Monitoring**: Memory usage tracking and limits

### Platform Compatibility
- **Risk**: Different drawing behavior across iOS/Android
- **Mitigation**: Extensive cross-platform testing
- **Monitoring**: Platform-specific test suites

### User Data Loss
- **Risk**: Unsaved work lost due to app crashes
- **Mitigation**: Auto-save mechanism every 30 seconds
- **Monitoring**: Crash reporting and recovery testing

## Next Phase Preparation

All research complete - no remaining NEEDS CLARIFICATION items. Ready for Phase 1 design and contracts generation.

**Research Completion Checklist**:
- [x] Drawing engine architecture defined
- [x] Storage strategy determined
- [x] Color management approach selected
- [x] Performance optimization strategy outlined
- [x] Testing approach established
- [x] Dependencies identified and justified
- [x] Risk mitigation strategies defined