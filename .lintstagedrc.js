module.exports = {
  '*.dart': (filenames) => [
    ...filenames.map((filename) => `fvm dart fix --apply ${filename}`),
    `fvm dart format ${filenames.join(' ')}`,
    'fvm flutter pub run import_sorter:main',
  ],
};
