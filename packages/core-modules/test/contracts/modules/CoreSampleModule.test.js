const assert = require('assert/strict');
const { getProxyAddress } = require('@synthetixio/deployer/utils/deployments');
const bootstrap = require('../../helpers/bootstrap');

const { ethers } = hre;

describe('CoreSampleModule', function () {
  const { deploymentInfo } = bootstrap();

  let CoreSampleModule;

  before('identify modules', async function () {
    const proxyAddress = getProxyAddress(deploymentInfo);
    CoreSampleModule = await ethers.getContractAt('CoreSampleModule', proxyAddress);
  });

  it('responds with the absolute truth', async function () {
    assert.equal(Number.parseInt(await CoreSampleModule.fortyTwo()), 42);
  });
});