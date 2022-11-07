import assert from 'assert/strict';

import { readPackageJson } from '../../../src/utils/misc/npm';

describe('utils/misc/npm.ts', function () {
  it('can retrieve the package.json of the project', function () {
    const pkg = readPackageJson();

    assert(pkg.name, '@synthetixio/core-utils');
  });
});