# Build System Documentation

## Project Structure

New folder-based structure for blog projects:

```
blog/
├── index.md              (Blog index)
├── blog1.md              (Top-level blog post)
├── sidebar.html          (Auto-generated)
├── topbar.html
└── abstract_algebra/     (Project folder)
    ├── abstract_algebra.md              (Home page for project)
    ├── michael_artin_Algebra_Chapter_2.md
    ├── michael_artin_Algebra_Chapter_5.md
    └── michael_artin_Algebra_Chapter_6.md
```

## Build Script Features

The enhanced `build-web.ps1` script now:

1. **Auto-scans blog subdirectories** - Detects all project folders
2. **Identifies home pages** - Files matching folder name are treated as project home page
3. **Generates sidebar automatically** - Creates `blog/sidebar.html` with:
   - Top-level items (index.html, blog1.html, etc.)
   - Collapsible project sections with all content pages
4. **Single-run execution** - Run once to build all HTML and regenerate sidebar

## Running the Build

### On Windows (Recommended):
```
Double-click: build.bat
```

### Manual PowerShell:
```powershell
.\build-web.ps1 -Force
```

### With Configuration:
```powershell
.\build-web.ps1 -ConfigFile build-config.json -Force
```

## Adding a New Project

1. Create a folder under `blog/`: `blog/my_project/`
2. Add markdown files:
   - `my_project.md` (Home page)
   - `my_project_chapter_1.md` (Content pages)
   - `my_project_chapter_2.md`
3. Run the build script - sidebar updates automatically

## Sidebar Auto-generation

The script generates `blog/sidebar.html` with:
- Collapsible sections for each project
- Direct links to all content pages
- Project names extracted from folder names
- Page names extracted from file names (underscores → spaces)

## Example Sidebar Output

For the abstract_algebra project:

```html
<ul>
  <li>
    <a class="blog-nav-item" href="index.html">📚 Blog Content</a>
  </li>
  <li>
    <a class="toggle-item" data-toggle="abstract-algebra">📖 Abstract Algebra <span class="toggle-btn">▼</span></a>
    <ul id="abstract-algebra" class="submenu expanded">
      <li><a href="abstract_algebra/abstract_algebra.html">Abstract Algebra (Home)</a></li>
      <li><a href="abstract_algebra/michael_artin_Algebra_Chapter_2.html">michael artin Algebra Chapter 2</a></li>
      <li><a href="abstract_algebra/michael_artin_Algebra_Chapter_5.html">michael artin Algebra Chapter 5</a></li>
      <li><a href="abstract_algebra/michael_artin_Algebra_Chapter_6.html">michael artin Algebra Chapter 6</a></li>
    </ul>
  </li>
  <li>
    <a class="blog-nav-item" href="blog1.html">blog1</a>
  </li>
</ul>
```

## Changes Made

1. **build-web.ps1** - Enhanced scanning and sidebar generation
2. **build.bat** - New Windows batch wrapper for easy execution
3. **blog/abstract_algebra/** - New project folder with content files
