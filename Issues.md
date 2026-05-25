You have to perform the following tasks for my attached neovim config files:

1. Write a separate lua file for theme only that defines the variable name of colors with their appropriate hexcode or whatever is method is appropriate. The variables from this file will be used throughout all the files in my neovim configuration. As a result, catppuccin nvim plugin must be moved to its own theme.lua file. So your `1st task` is to create and write a new theme.lua file, so that I can easily change to add themes if I wanted to. _You may need to create new files and/or only write out the changes needed for this `1st task`_.

2. Your `2nd task` is then to rewrite the final ui.lua file as well with all the changes.

3. When I navigating any file opened using neovim, pressing any arrow once moves the cursor once but holding the key down does not continuously move the arrow. Only after pressing the same key again and holding it down continues to move the the cursor. I want this behavior to happen after the 1st press of any arrow key. `Everything here that I need you to do is your 3rd task`. Rewrite the whole file that need changes for this 3rd task.

4. Before integrating the git.lua file from the changesv1.md file, I need to some stuff about gitsigns.nvim: what does the following things do for git in general,

```lua
topdelete    = { text = "⎴" },
changedelete = { text = "▍" },
untracked    = { text = "┆" },
```

as well as the following

```lua
linehl = false,
numhl = false,
```

Also the changesv1.md removed diffview.nvim when rewriting git.lua. What could be the justification for that. Also for gitsigns configuration should be updated to use only "▎", for add, change and delete. Catppuccin green for adding, catppuccin yellow for change and catpuccin red for delete. You should highlight the lines with line and line number with the matching colors, if and only if, what I think linehl and numhl does for gitsigns is correct. `Everything here that I need you to do is your 4th task`. _Then rewrite the whole git.lua file with the changes and corrections for this `4th` task as well as integrations from the attached changesv1.md file._

5. The markdown.lua code block in the attached changesv1.md file removed many of the code from my separately attached markdown.lua file.I only need the code for markdown folding removed. Also modernize the render-markdown.nvim plugin so that that the markdown file is easier to read and pleasing to the eye. As a result, neovim would become a capable markdown editor and viewer. Also since I need to write `**` in pairs in a markdown file in insert mode, they should appear in 2, 4 and 6, numbers with the cursor placed in the middle while in insert mode. Also, I only use `---` for rendering the separation lines and I don't use `***`, which essentially does the same thing, when I press `-` it should always appear as `---` followed by an automatic movement to the next line (likely a cr behaviour). Search the web and add any other plugins that may improve the experience handling markdown files with neovim. Keep in mind that my attached markdown.lua file has a template for a `.markdownlint-cli2.yaml` file. If this file is missing from the root directory of a markdown file, this file must be created when creating a new markdown file in the same folder or opening an existing markdown. Make sure that the existing `.markdownlint-cli2.yaml` must never be overwritten. `Everything here that I need you to do is your 5th task`. _Then rewrite the whole markdown.lua file with the changes and corrections for this `5th` task as well as integrations from the attached changesv1.md file._

6. Remove the plugin responsible for the special cmdline that appears at the bottom in neovim, e.g., when I press :wq. I need the default befaviour of neovim in this case. `Everything here that I need you to do is your 6th task`. _Only write out the changes needed for any files related to this `6th task`_.

7. Also completions should be navigated using the tab that cycles so that tab key cycles to the selection candidates, but when a tab has a selection candidate highlighted, neovim should automatically enter the selected candidate without user intervention. Pressing tab moves the selection down and then cycles to the top and Shift+tab moves the selection up and cycles back to the bottom of the list. `Everything here that I need you to do is your 7th task`. _Only write out the changes needed for any files related to this `7th task`_.

8. Apply many of the features from https://nvchad.com/docs/features without adding any new plugins. `This is your 8th task`. You are not allowed to proceed with the `8th task` until you have read all the contents from the provided nvchad link. _You may create new files and/or only write out the changes needed for the `8th task`_.

9. Also use nvchad-like ui elements whereever possible for all the plugins. Search the web and think longer for this task. `This is your 9th task`. _You may create new files and/or only write out the changes needed for this `9th task`_.

10. While in visual mode, I select the lines I want to copy and then I press `y` to yank the content. When I paste the yanked content over a new area using `p`, where there may be existing content, pressing `p` again does not paste the yanked content but instead pastes the existing content I pasted over from the previous paste action. Fix this behaviour so that the yanked content is pasted and not the existing content.`This is your 10th task`. _Only write out the changes needed for any files related to this `10th task`_.

11. Your `11th task` is create a new file called latex.lua and write a comprehensive latex writing environment using the texlive installation in my linux system as well as utilizing lsp features using texlab, and any formatting and linting capabilities. I must have completions for all sorts of things that is not just limited to lsp completions, but also for latex macros and other things that makes me efficient in writing tex files using neovim. latex.lua file will use zathura as the pdf renderer. But I will also need the ability to preview mathematical equations and any other symbols inline and within latex blocks as images. I am using the kitty terminal to use neovim. `Everything here that I need you to do is your 11th task`. _You may need to create new files and/or only write out the changes needed for this `12th task`_.

12. Your `12th task` is to add any other plugins, not already installed, that I might benefit from. The goals of my neovim configuration are to be a fully-fledge IDE as well as a capable text editor for writing scientific documents. _You may need to create new files and/or only write out the changes needed for this `12th task`_.

13. There is annoying thing I do while typing: when intending to press `y` for yanking purposes, I accidentally press `u` over the selected content in visual model. Your `13th task` is to find a clever solution so that I have fewer such occurances. It is upto you to decide what to do in this case. _Only write out the changes needed for any files related to this `13th task`_.

14. Also the smart wrapping behaviour for markdown files and any latex related files, including, tex and bib files should be much smarter than what the typical wrapping behavior in neovim does. Search the web and think longer for this task. `This is your 14th task`. _Only write out the changes needed for any files related to this `14th task`_.

15. Your `final task` is to rewrite the whole attached README.md in its entirety to account for all the new files and changes to the existing uploaded files.

When doing all the tasks, you have to consider the attached changesv1.md as well as all the attached markdown files. Search the web and think longer for all the tasks. The information you get must be the latest till May 2026. You are not permitted to rewrite any existing files unless I specifically ask you to do so.

---

~/.config/nvim/
├── init.lua # Runtime Bootstrapper & Lazy Engine Setup
├── selene.toml # Strict Lua Verification Code Linter Configurations
└── lua/
├── core/
│ ├── options.lua # Global System Settings, Options & Timing Flags
│ ├── keymaps.lua # Clipboard Protections, Safety Bindings & Maps
│ └── autocmds.lua # Global File Event Operational Lifecycles
└── plugins/
├── theme.lua # Catppuccin Palette Core & NvChad Elements Overrides
├── ui.lua # Indentation Visual Trackers & Gutter Elements
├── completion.lua # Blink.cmp Fast Tab Cycling Logic Modules
├── lsp.lua # Diagnostic Navigation & Troubleshoot Viewers
├── mason.lua # Automatic Package Manager Tool Setup Installs
├── formatter.lua # Conform Async Auto-Format Pipeline Triggers
├── lint.lua # Nvim-Lint Structural Code Engine Analysts
├── git.lua # High-Density Line Gitsigns Highlighters
├── markdown.lua # Smart Typography, Pairs, & Automated Local Linters
├── latex.lua # Vimtex LaTeX Compiler & Inline Math Render Engines
├── ide_extensions.lua # Visual Structural Outline Frameworks
└── tools.lua # Telescope, Neo-Tree Explorer & Search Mechanics

Repeat all the tasks in the previous prompt. Then find and fix any errors and issues. Also determine if options.lua, keymaps.lua and autocommands can be further enhanced. Then rewrite the whole neovim configuration in the form a markdown file that contains markdown code blocks for the whole neovim source tree. The whole markdown file must contain the whole content of the following files in their respective markdownd code blocks with all the changes and corrections:

- init.lua
- lua/core/options.lua
- lua/core/keymaps.lua
- lua/core/autocmds.lua
- lua/plugins/theme.lua
- lua/plugins/ui.lua
- lua/plugins/completion.lua
- lua/plugins/lsp.lua
- lua/plugins/mason.lua
- lua/plugins/formatter.lua
- lua/plugins/lint.lua
- lua/plugins/git.lua
- lua/plugins/markdown.lua
- lua/plugins/latex.lua
- lua/plugins/ide_extensions.lua
- lua/plugins/tools.lua

Search the web and think longer for all the tasks. And make sure the information you get is the latest till May 2026.

Then in a separate markdown code block write the full, corrected README.md file inside simple txt markdown code block.

---

---

---
