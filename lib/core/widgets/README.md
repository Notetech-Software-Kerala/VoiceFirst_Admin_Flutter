# Global Design Standards

This directory contains the core reusable widgets that enforce the application's global design system. All new pages and lists should verify against these standards to ensure consistency.

## 1. StandardPageLayout
**Location:** `lib/core/widgets/standard_page_layout.dart`

A standardized page wrapper that replaces `Scaffold`. It provides a consistent "Sticky Header" design with a built-in search bar and support for both sliver-based and box-based content.

### Features
- **Sticky Header**: Automatically handles the sliver app bar with title and back button.
- **Search Bar**: Built-in valid search bar if `searchController` is provided.
- **Slivers or Body**: Supports `slivers` (for complex lists) or `body` (for static content).
- **Responsive**: Adapts to theme (dark/light) automatically.

### Usage
```dart
return StandardPageLayout(
  title: "My Page Title",
  
  // Search Functionality
  searchController: _myController, // optional
  onSearchChanged: (val) => _performSearch(val), // optional
  searchHint: "Search items...",
  
  // Custom Leading Widget (optional)
  // leading: Icon(Icons.menu), // Overrides default Back/Menu logic
  
  // Content (Choose one)
  slivers: [
    SliverList(...)
  ],
  // OR
  // body: Center(child: Text("Hello")),
  
  // Actions
  onRefresh: () async => await _refreshData(),
  floatingActionButton: FloatingActionButton(...),
);
```

## 2. StandardListCard
**Location:** `lib/core/widgets/standard_list_card.dart`

A standardized list item card used for displaying entities (Roles, Users, Post Offices, etc.) in a list.

### Features
- **Uniform Styling**: Consistent padding, border radius, and shadow.
- **Flexible Layout**: Leading icon, Title, Subtitle, and Trailing actions.
- **Action Buttons**: Helper `StandardActionButton` for consistent Edit/Delete buttons.

### Usage
```dart
return StandardListCard(
  title: "Item Name",
  subtitle: "Description or secondary info",
  
  // Leading Icon
  leading: StandardIconBox(
    icon: Icons.person, 
    color: Colors.blue
  ),
  
  // Action Buttons
  actions: [
    StandardActionButton(
      icon: Icons.edit, 
      color: Colors.grey, 
      onTap: () => _edit(),
    ),
    StandardActionButton(
      icon: Icons.delete, 
      color: Colors.red, 
      onTap: () => _delete(),
    ),
  ],
);
```

## 3. Global Bottom Sheets
**Location:** `lib/core/widgets/`

### Delete Confirmation
Use `showDeleteBottomSheet` instead of `AlertDialog` for deletions.
```dart
showDeleteBottomSheet(
  context: context,
  itemName: "Admin Role",
  onDelete: () => _performDelete(),
);
```

### Recovery
Use `showRecoveryBottomSheet` for recovering items (if applicable).
```dart
showRecoveryBottomSheet(
  context: context,
  onRecover: () => _performRecovery(),
);
```
