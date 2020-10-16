import { expect } from '../../../setup'

/* External Imports */
import { ethers } from '@nomiclabs/buidler'
import { Contract } from 'ethers'
import { MockContract, smockit } from '@eth-optimism/smock'
import { randomBytes, hexlify } from 'ethers/lib/utils'

const runSteps = async (
  Lib_RingBuffer: Contract,
  steps: any[]
): Promise<void> => {
  for (const step of steps) {
    if (step.fn === 'push') {
      for (let i = 0; i < step.args; i++) {
        await Lib_RingBuffer.push(
          hexlify(randomBytes(32)),
          hexlify(randomBytes(27))
        )
      }
    } else if (step.fn === 'get') {
      for (let i = 0; i < step.args; i++) {
        await Lib_RingBuffer.get(step.args[i])
      }
    } else if (step.fn === 'getrevert') {
      for (let i = 0; i < step.args; i++) {
        try {
          await Lib_RingBuffer.get(step.args[i])
          throw new Error('DID NOT REVERT')
        } catch (err) {}
      }
    }
  }
}

describe('Lib_RingBuffer', () => {
  let Mock__iRingBufferOverwriter: MockContract
  before(async () => {
    Mock__iRingBufferOverwriter = smockit(
      await ethers.getContractFactory('iRingBufferOverwriter')
    )
  })

  let Lib_RingBuffer: Contract
  before(async () => {
    Lib_RingBuffer = await (
      await ethers.getContractFactory('TestLib_RingBuffer')
    ).deploy()

    await Lib_RingBuffer.init(16, Mock__iRingBufferOverwriter.address)
  })

  describe('stress tests', () => {
    before(async () => {
      Mock__iRingBufferOverwriter.smocked.canOverwrite.will.return.with(true)
    })

    it('should hold up to a stress test', async () => {
      const steps = [
        {
          fn: 'push',
          args: 16,
        },
        {
          fn: 'push',
          args: 16,
        },
        {
          fn: 'get',
          args: [0, 1, 2, 3, 4, 5, 6, 7, 8, 16, 31],
        },
        {
          fn: 'getrevert',
          args: [32],
        },
        {
          fn: 'push',
          args: 1,
        },
        {
          fn: 'get',
          args: [1, 32],
        },
        {
          fn: 'getrevert',
          args: [0],
        },
        {
          fn: 'push',
          args: 7,
        },
        {
          fn: 'get',
          args: [33, 34, 35, 36, 37, 38, 39],
        },
        {
          fn: 'getrevert',
          args: [0, 1, 2, 3, 4, 5, 6, 7, 8, 40, 41, 42],
        },
        {
          fn: 'push',
          args: 8,
        },
        {
          fn: 'get',
          args: [40, 41, 42, 43, 44, 45, 46, 47],
        },
        {
          fn: 'delete',
          args: 8,
        },
        {
          fn: 'get',
          args: [38, 39],
        },
        {
          fn: 'getrevert',
          args: [9, 10, 11, 12, 13],
        },
        {
          fn: 'getrevert',
          args: [40, 41, 42, 43, 44, 45, 46, 47],
        },
      ]

      await runSteps(Lib_RingBuffer, steps)
    })
  })
})
