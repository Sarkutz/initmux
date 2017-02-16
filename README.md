
# What This Program is?

This is just another store/initializer for Tmux.

# What kind of person should use it?

Well. If you got this far, it probably means you have grown up and changed from [yakuake](https://yakuake.kde.org/) or [terminator](https://gnometerminator.blogspot.com.br/p/introduction.html) to tmux. But then you realized you are losing a lot of time with repeatitive tasks just to start you work, like:

1. Entering your project's directory
2. Opening your text editor of choice
3. Spliting tmux windows and creating more windows
4. I could go on ...

the point is that all programers do some kind of laboring job before really getting into work. And that doesn't mean you'll have to repeat those task each time you go to your project.

And what about when you get used to a layout? I mean, when you let's say create a window splited in half, with a specific command runing in one of them and your editor in the other. Does it mean you'll have to create that perfect environment all over again next time you decide to do some code? Just the thought gives me the chills. That's why I created IniTmux.

# How does it works?

It's simple. All you have to do is plan your sessions into YAML files, drop
them into `~/.config/IniTmux` and execute a single python script `src/main.py`.

# How Do I Plan My Sessions?

Let's say that you want to accomplish the following workspace:

```text
     Session: Files

     Window: Musics
     Layout: even-vertical
     +-------------------+-------------------+
     |                   |                   |
     |                   |                   |
     |                   |                   |
     |                   |                   |
     |                   |                   |
     |      mocp .       |      ranger       |
     |   (~/Musics)      |    (~/Musics)     |
     |                   |                   |
     |                   |                   |
     |                   |                   |
     |                   |                   |
     |                   |                   |
     |                   |                   |
     +-------------------+-------------------+

     Window: Downloads
     Layout: even-horizontal
     +---------------------------------------+
     |                                       |
     |               ranger                  |
     |            (~/Downloads)              |
     |                                       |
     |                                       |
     |                                       |
     +---------------------------------------+
     |                                       |
     |            watch du -sh .             |
     |            (~/Downloads)              |
     |                                       |
     |                                       |
     |                                       |
     +---------------------------------------+
```

to accomplish that, you must write the following `YAML` file:

```yaml
---
name: Files
root: '~'      # Do not put the last slash ('/')

windows:
- Musics    : musics
- Downloads : downloads

models:
    musics:
        layout: even-vertical
        dir: <WindowName> 
        panes:
        - mocp .
        - ranger
    downloads:
        layout: even-horizontal
        dir: <WindowName> 
        panes:
        - ranger
        - watch du -sh .
```

# YAML Syntax for IniTmux

It is very simple. A `YAML IniTmux` file has up to 4 main attributes:

### name (String)

```yaml
name: <SessionName>
```

Is the name of the session. This attribute is required. 

### root (String)

```yaml
root: <RootDirectory>
```

Is the root directory of all windows. This attribute is optional. If defined, its value will be added before the `dir` attribute, which will be explained soon.

Note: If you want to refer to `~`, please use `'~'` or `"~"` not only `~`. This symbol will be expanded to the 
HOME location of the user who called the script. It uses `os.path.expanduser` of `os` python module.

### models

They are a sort of ***skeleton*** for your windows description. You can describe a model which can be applied to several windows at once.

See the power of the `models` attribute in the following example:

* `~/.config/IniTmux/Packagers.yml`
```yaml
---
name: Packagers
windows:
- Pacman : two
- Yaourt : two
- npm    : two
- gem    : two
- pip    : two
models:
    two:
        layout: even-horizontal
        panes: 2
```

well that is it. With this configuration, IniTmux will create a session called `Packagers` with 5 windows. In each window, IniTmux will apply the model called `two`, which will create 2 (`two`) panes without commands. 

You can also see that both `root` and `dir` attributes were not written. In this case, IniTmux will change 
directory to HOME (`~`).

### windows 

Is the list of window names, model names and possible specific directory for all the panes of that window. This 
attribute is required. 


There are 4 ways to describe a window.

###### Direct Form

In this form, you describe the window without using any model. Example:

```yaml
windows:
- Directories:
    layout: tiled
    panes: 
    - cd
    - cd /
    - cd /usr
    - cd /boot
```

this will create 1 window called `Directories` with 4 panes.

###### Model Form

In this form, you describe a set of models and apply then in each window. Example:

```yaml
windows:
- Torrents: two
- Downloads: two
- Documents: three
models:
    three:
        layout: even-horizontal
        dir: <WindowName>
        panes: 3
    two:
        layout: even-horizontal
        dir: <WindowName>
        panes: 2
```

###### Overwrite Model Form

In this form, you describe a set of models and apply then in each window, but you can 
overwrite one or more attibutes of a model if you want. Example:

```yaml
windows:
- Library1: 
    layout : tiled
    model  : two

- Library2: 
    model  : two
    dir    : ''
    layout : tiled

models:
    three:
        layout: even-horizontal
        dir: <WindowName>
        panes: 3
    two:
        layout: even-horizontal
        dir: <WindowName>
        panes: 2
```

Note:
    Until this moment, you cannot overwrite the `panes` attribute yet. This part of the 
    code (or even the entire code) was written in a hurry, and still lacks of organization. With time, I'll take 
    care of this feature.

###### Numeric Form

Occurs when you want to create a window describing only its `number of panes`. In this case, IniTmux will take 
default values for `dir` and `layout` attributes, which is `''` for both. I also have to say that no command will
be executed for each pane.

The syntax is:

```yaml
windows:
- <WindowName> : <NumberOfPanes>
```

Example:

```yaml
---
name: Doc
root: /i/conf/doc

windows:
- man    : ranger
- vim    : ranger
- sh     : ranger
- python : ranger

- Root: 2 # This window is described in Numeric Form

models:
    ranger:
        layout: "076b,113x31,0,0[113x23,0,0,0,113x8,0,24,1]"
        dir: <WName>
        panes:
            - ranger
            - ''
```

###### Command Form

Occurs when you want to create a window, with a single pane, and execute a command inside this pane. In this case, IniTmux will assume default values for `layout` and `dir`.

The syntax is:

```yaml
windows:
- <WindowName> : <Command>
```

Example:

```yaml
---
name: Doc
root: /i/conf/doc

windows:
- man    : ranger

- Root: 2               

- other : watch df -h   # This window is described in Command Form

models:
    ranger:
        layout: "076b,113x31,0,0[113x23,0,0,0,113x8,0,24,1]"
        dir: <WName>
        panes:
            - ranger
            - ''
```

Note: If you have created a model with the same name of the command that you want to use in this case, IniTmux will apply the model instead of the single command. But, there is a trick you can do to avoid this. See this example:

```yaml
---
name: Test
windows:
- A: tree
- B: tree
- C: 'tree '

models:
    tree:
        panes: 2
```

See what I did here? I put the command inside `'` `'`, with a space after the command.

###### Yes, you can mix all these forms together when describing windows

Example:

```yaml
---
name: Test
root: '~'
windows:
- Directories:      # Direct Form
    layout: tiled
    panes: 
    - cd
    - cd /
    - cd /usr
    - cd /boot

- Library: three            # Model Form

- Books:                    # Overwrite Form
    model: two
    dir: 'Documents/Livros'
    layout: tiled

- Doc: 3                     # Numeric Form

- other : watch df -h        # Command Form

models:
    three:
        layout: even-horizontal
        dir: <WindowName>
        panes: 3
    two:
        layout: even-horizontal
        dir: <WindowName>
        panes: 2
```

# Panes Description

You can describe panes in 3 different forms:

###### Number form

You are only interested in create a number of panes and apply no commands. Example:

```yaml
models:
    three:
        layout: even-horizontal
        dir: <WindowName>
        panes: 3

    two:
        layout: even-horizontal
        dir: <WindowName>
        panes: 2

    four:
        layout: even-horizontal
        dir: <WindowName>
        panes: 4
```

###### One Command Form

You want to create several panes and apply a single command after their creation. Example:

```yaml
    three:
        layout: "40fd,113x31,0,0[113x22,0,0{22x22,0,0,0,90x22,23,0,1},113x9,0,23,2]"
        dir: <WName>
        panes:
        - loop "tree obj" 0.5
        - vim -c LoadWorkSpace
        - ''
```

###### Multiple Commands Form

You want to create several panes and apply several commands, in sequence, for each pane. Example:

```yaml
models:
    three:
        layout: even-horizontal
        dir: <WindowName>
        panes: 3
    two:
        layout: even-horizontal
        dir: <WindowName>
        panes: 
            - ListDirs: # Multiple commands. The pane's name is irrelevant, but not optional
                - cd ~
                - ls
                - cd /
                - ls
                - cd /usr
                - ls
                - cd /boot
                - ls
            - ranger
            - df -h
```

as you can see, you can mix `One Command` and `Multiple Command` Forms together.

# IniTmux Wildcards

To support the `models` feature, I had to implement some sort of wildcards, so I can 
reference inside the model something about the window or the session. In another 
private project, I'm using git with feature branch workflow. Each feature has its own 
branch and also its own directory. The directory structure of the `Math` main 
branch is the following.

```text
$ tree -L 1 -d /i/project/LibAK/feature/Math
.
├── Bool
├── branch
├── Complex
├── Integer
├── Matrix
├── Number
├── Real
└── Vector
```

All of these directories, except `branch`, has a lot in common when creating windows for each one of them.

1. The name of the directory will be the name of the window;
2. All windows will share the same layout;
3. All windows will have the same structure for each pane.

For the `branch` directory, I like to make specific description about the window creation. 

So, to accomplish this, and take advantage of the similarities, I've created the following YAML file.

* samples/AK-MATH.yml

```yaml
---
name: AK-Math 
root: /i/project/LibAK/feature/Math
windows:
- Matrix  : feature
- Vector  : feature
- Number  : feature
- Complex : feature
- Real    : feature
- Integer : feature
- Bool    : feature

- Math:
    layout : tiled
    dir    : branch
    panes  :
    - 'ranger'
    - ''

models:
    feature:
        layout: "40fd,113x31,0,0[113x22,0,0{22x22,0,0,0,90x22,23,0,1},113x9,0,23,2]"
        dir: <WName>
        panes:
        - loop "tree obj" 0.5
        - vim -c VWSLoadWorkSpace
        - ''
```

in this case, I have just one model (`feature`). You can see that `dir` attribute has the `<WName>`
wildcard, that will be expanded to the name of the window that "called" the model `feature`. And, you 
can also see that I've described specific settings for the `Math` window, once it has specific requirements.

### List of Possible Wildcards

A wildcard can be used inside any of the following attibutes: `root`, `dir`, and inside any command line described into `panes` attibutes.

Each wildcard must be written inside `<` and `>`. What will be inside can vary as follows:

1. `wname`, `winname`, `windname`, and `windowname`. Example:

all of these wildcards will be expaded to the window's name.

```text
    dir: 'feature/<WindName>'
```

2. `sname`, `sesname`, `sessname`, and `sessionname`. Example:

all of these wildcards will be expaded to the sessin name.

```text
    root: '~/<SessionName>'
    dir : 'feature/<SName>/trash/<WName>'
    panes:
    - cd /i/project/<sname>
    - cd
```

you can write a wildcard ignoring the case of the letters. This can be done thanks to Python's regex module. 
In the code, the pattern variables for these wildcards are:

```python
WPattern = r"<(?i)(windown|wn|winn|windn)ame>"
SPattern = r"<(?i)(sessionn|sn|sesn|sessn)ame>"
```

and they are used only inside the function `CreatePanes`. So, if you want to change them, please let me know.

# Related Projects

If IniTmux does not suit your needs, then you can take a look at these projects:

1. [Tmuxinator](https://github.com/tmuxinator/tmuxinator)
2. [Teamocil](https://github.com/remiprev/teamocil)

# Tips

1. If you use `vim` or `neovim`, then checkout my other project called [VWS](https://github.com/iasj/VWS). It stands for Vim WorkSpace. It does basicaly the same as IniTmux, but less powerful.
2. If you are new to tmux, maybe my [configurations](https://github.com/iasj/tmux) can help you avoid the bible of tmux's man page.
 
# Dependencies

###### pyyaml

I strongly recommend you to install it with pip.

    $sudo pip install pyyaml

# TODO

1. Reload Operations
2. Console Argument Parser
3. Install and Uninstall Script
