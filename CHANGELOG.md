# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [1.1.0](https://github.com/ArmandPhilippot/dotig/compare/v1.0.0...v1.1.0) (2021-07-11)


### Features

* add a verbose option for each command ([b00f7f6](https://github.com/ArmandPhilippot/dotig/commit/b00f7f62daaf868108e7a98e0ca0fb9cb107cf47))
* **commit:** add an option to commit only tracked files ([66e7dc3](https://github.com/ArmandPhilippot/dotig/commit/66e7dc3cec545330554b30065428604bcec40812))
* **commit:** add an option to commit only untracked files ([0e9b060](https://github.com/ArmandPhilippot/dotig/commit/0e9b0603e35288931b58de90a8bf6ed297646d70))
* **commit:** add an option to provide the commit msg from CLI ([0b78e2f](https://github.com/ArmandPhilippot/dotig/commit/0b78e2fcaac8dcb7ad4c654084fbe808592e6abb))
* **status:** add an option to list the dirty files ([01c80d0](https://github.com/ArmandPhilippot/dotig/commit/01c80d08a7dcf950dfbe6f08ebff13557775ba26))
* print a different invalid usage message depending on the command ([16c1efd](https://github.com/ArmandPhilippot/dotig/commit/16c1efda8cc24826911e055f44f5533254bc5682))
* **update:** add an option to always skip duplicate files ([9fee271](https://github.com/ArmandPhilippot/dotig/commit/9fee27123e935acf2f50d916d97a4596fac1e886))
* **update:** add an option to skip all conflicts ([4b0a203](https://github.com/ArmandPhilippot/dotig/commit/4b0a203b909a72f2c73b34f05514aca90febea6b))
* **update:** add an option to skip conflict when target is different ([294ecb4](https://github.com/ArmandPhilippot/dotig/commit/294ecb48996fc24ce837bb381cfb17084da18b20))
* add help menu for each commands ([ca3b39b](https://github.com/ArmandPhilippot/dotig/commit/ca3b39ba0367fabea24346c25b62867ccad9fc82))


### Bug Fixes

* enforce trailing slash for $DOTFILES path in CLI commands ([dc2e9fb](https://github.com/ArmandPhilippot/dotig/commit/dc2e9fb90aa8abb0f440369d809467f4694acab2))
* **add:** display filename if it is not a file ([7e7f4fc](https://github.com/ArmandPhilippot/dotig/commit/7e7f4fcd59361d2945ddbe6b6160dbd0a49ad7da))

## [1.0.0](https://github.com/ArmandPhilippot/dotig/compare/v0.1.0...v1.0.0) (2021-06-30)


### Features

* add `rm`/`remove` arguments to remove symlinks from CLI ([d6f974e](https://github.com/ArmandPhilippot/dotig/commit/d6f974ee1b9774ea6faf597152356872a1014194))
* add a `--version` argument to print Dotig version and updates ([df7d5fe](https://github.com/ArmandPhilippot/dotig/commit/df7d5fed083eb825e5cf7c1add779dcfa03b0a4d))
* add a command to display the repo status from CLI ([b58ed69](https://github.com/ArmandPhilippot/dotig/commit/b58ed691c48c5dec0e7e1bc0e9f03a10f17f9d45))
* add a verbose option ([1549ccc](https://github.com/ArmandPhilippot/dotig/commit/1549ccce9988a130ca759cdf1ae834c9a98caecf))
* add an `add` argument to backup new dotfiles ([0811955](https://github.com/ArmandPhilippot/dotig/commit/08119559d817400005f12d3dd14a53a192e283a7))
* add an `update` argument to update symlinks from CLI ([c6a8c48](https://github.com/ArmandPhilippot/dotig/commit/c6a8c4889aa901a1eb61db2fe3d81bf5b9ea8252))
* add an option to skip repo status ([d41f406](https://github.com/ArmandPhilippot/dotig/commit/d41f406aeb31624b2bceca0486be6fc6484c2a0d))
* add an option to update Git submodules ([881b9a3](https://github.com/ArmandPhilippot/dotig/commit/881b9a36faded9ceb4ceeceb1c2fa41cdfe84bf8))
* add XDG_STATE_HOME to XDG paths ([9494ca6](https://github.com/ArmandPhilippot/dotig/commit/9494ca63dd477fe7527cec7b1525e663d4e9e044))
* init submodules (if any) during repo setup ([8e13754](https://github.com/ArmandPhilippot/dotig/commit/8e13754789bbc43cc99031f38c87d224ee3190f9))
* provide a help option ([97e55c7](https://github.com/ArmandPhilippot/dotig/commit/97e55c728ef89b45d6bc0a4cf8c90f77b388bc7d))
* provide arguments to execute Git options from CLI ([33c5c47](https://github.com/ArmandPhilippot/dotig/commit/33c5c47300e6042d790b7473ade9a7553f5e5312))
* provide CLI commands in addition to the menu ([906af73](https://github.com/ArmandPhilippot/dotig/commit/906af7364ac37e53523a03f3d98ab50ea54ccff0))
* use XDG paths ([3b454dd](https://github.com/ArmandPhilippot/dotig/commit/3b454ddc8b08d8ccc1a60415ce033f097d0545e2))


### Bug Fixes

* define a more compatible way to set upstream ([9c33b74](https://github.com/ArmandPhilippot/dotig/commit/9c33b74d2d92534b5f06a2dc26da305006ab8be0))
* enforce trailing slash in backup path ([d8bcdd3](https://github.com/ArmandPhilippot/dotig/commit/d8bcdd3bb4425d4237b015975719422378eb6e21))
* enforce trailing slash only for directories ([239fbb8](https://github.com/ArmandPhilippot/dotig/commit/239fbb8766614f761d21c13649ebb62b07c7eefd))
* prevent script to exit if a symlink target does not exist ([3e862e9](https://github.com/ArmandPhilippot/dotig/commit/3e862e9b08afb18a24f234aaabaea815d2090c28))
* **add:** check if file exists before trying to move file ([066c7c6](https://github.com/ArmandPhilippot/dotig/commit/066c7c6324e1ca751e6740e829ea414fa2a4fb88))
* **add dotfiles:** check if file using home shorthand exists ([d0cf152](https://github.com/ArmandPhilippot/dotig/commit/d0cf1521f80968ae3bcc7e338cb5815df211ba25)), closes [#066c7c6](https://github.com/ArmandPhilippot/dotig/issues/066c7c6)
* **CLI:** handle multiple options ([1674eb4](https://github.com/ArmandPhilippot/dotig/commit/1674eb499abc6b0bc374e0600e5135208de480ab))
* **update:** correct typo in variable names ([1bdd4aa](https://github.com/ArmandPhilippot/dotig/commit/1bdd4aaee09b471d9718e4f8f936135c9e89b05b))
* prevent variable name collision in repo configuration ([ebf0ad1](https://github.com/ArmandPhilippot/dotig/commit/ebf0ad1dc1258ab2525d8cb7cdf95867eb8e561b))
* retrieve unpushed commits only if at least 1 local commit exists ([09e2cc3](https://github.com/ArmandPhilippot/dotig/commit/09e2cc3ab619b52660abf4960d999b65009ea8e0))
* **CLI:** combine options and command ([2831b74](https://github.com/ArmandPhilippot/dotig/commit/2831b744fec4051b2595be2c8ea4b2f204e54ba8))
* **repo status:** call fetch before setting commits refs ([b10ed99](https://github.com/ArmandPhilippot/dotig/commit/b10ed995940cac174dedc09901141504778cae69))
* **update:** remove broken symlinks while updating all symlinks ([1efa9b8](https://github.com/ArmandPhilippot/dotig/commit/1efa9b8302470156a213eb7671c3eff98253894b))

## 0.1.0 (2021-06-19)


### Bug Fixes

* **git init:** set uptstream if not set ([8281d14](https://github.com/ArmandPhilippot/dotig/commit/8281d14ad5951c407e04ce87cdac6ba9b5ece0e3))
* add staged modified files to staged files count ([331f8db](https://github.com/ArmandPhilippot/dotig/commit/331f8db3c43625fee7d6e52230491276f8d3f0e6))
* avoid stopping script if there are no release ([183f82d](https://github.com/ArmandPhilippot/dotig/commit/183f82dcb20126bc4d871647dd79e5f515ded7b3))
