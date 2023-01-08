import _ from 'lodash';
import { ethers } from 'ethers';
import Debug from 'debug';
import { JTDDataType } from 'ajv/dist/core';

import {
  ChainBuilderContext, 
  ChainBuilderRuntimeInfo, 
  ChainArtifacts, 
  registerAction 
} from '@usecannon/builder';

import { getContractDefinitionFromPath, getContractFromPath, getMergedAbiFromContractPaths } from '@usecannon/builder/dist/util';

import { generateRouter } from '../generate';
import { DeployedContractData } from '../types';
import { compileRouter } from '../compile';

const debug = Debug('router:cannon');

const config = {
  properties: {
    contracts: { elements: { type: 'string' } },
  },
  optionalProperties: {
    from: { type: 'string' },
    depends: { elements: { type: 'string' } },
  },
} as const;

export type Config = JTDDataType<typeof config>;

// ensure the specified contract is already deployed
// if not deployed, deploy the specified hardhat contract with specfied options, export address, abi, etc.
// if already deployed, reexport deployment options for usage downstream and exit with no changes
const routerAction = {
  validate: config,

  async getState(runtime: ChainBuilderRuntimeInfo, ctx: ChainBuilderContext, config: Config) {
    if (!runtime.baseDir) {
      return null; // skip consistency check
      // todo: might want to do consistency check for config but not files, will see
    }

    const newConfig = this.configInject(ctx, config);

    const contractAbis = {};

    for (const n of newConfig.contracts) {
      const contract = getContractFromPath(ctx, n);
      if (!contract) {
        throw new Error(`contract not found: ${n}`)
      }

      
    }

    return {
      contractAbis,
      config: newConfig,
    };
  },

  configInject(ctx: ChainBuilderContext, config: Config) {
    config = _.cloneDeep(config);

    config.contracts = _.map(config.contracts, (n: string) => _.template(n)(ctx));

    if (config.from) {
      config.from = _.template(config.from)(ctx);
    }

    return config;
  },

  async exec(runtime: ChainBuilderRuntimeInfo, ctx: ChainBuilderContext, config: Config, currentLabel: string): Promise<ChainArtifacts> {
    debug('exec', config);

    const contracts: DeployedContractData[] = config.contracts.map(n => {

      const contract = getContractDefinitionFromPath(ctx, n);
      if (!contract) {
        throw new Error(`contract not found: ${n}`)
      }

      return {
        constructorArgs: contract.constructorArgs,
        abi: contract.abi,
        deployedAddress: contract.address,
        deployTxnHash: contract.deployTxnHash,
        contractName: contract.contractName,
        sourceName: contract.sourceName,
        contractFullyQualifiedName: `${contract.sourceName}:${contract.contractName}`,
      }
    });

    const contractName = currentLabel.slice('router.'.length);

    const sourceCode = await generateRouter({
      contractName,
      contracts
    });

    const solidityInfo = await compileRouter(contractName, sourceCode);

    const signer = config.from ? 
      await runtime.getSigner(config.from) : 
      await runtime.getDefaultSigner!({ data: solidityInfo.bytecode });

    const deployedRouterContract = await ethers.ContractFactory.fromSolidity(solidityInfo).connect(signer).deploy();

    await deployedRouterContract.deployed();

    return {
      contracts: {
        [contractName]: {
          address: deployedRouterContract.address,
          abi: getMergedAbiFromContractPaths(ctx, config.contracts), // the abi is entirely basedon the fallback call so we have to generate ABI here
          deployedOn: currentLabel,
          deployTxnHash: deployedRouterContract.deployTransaction.hash,
          contractName,
          sourceName: contractName + '.sol',
        }
      }
    };
  },
};

registerAction('router', routerAction);
