import { existsSync, mkdirSync, readFileSync } from 'fs';
import { MpcState, mpcStateFromJSON } from 'setup-mpc-common';
import { defaultState } from './default-state';
import { renameAsync, writeFileAsync } from './fs-async';

export interface StateStore {
  setState(state: MpcState): Promise<void>;
  getState(): Promise<MpcState>;
}

export class MemoryStateStore {
  private state!: MpcState;

  public async setState(state: MpcState) {
    this.state = state;
  }

  public async getState(): Promise<MpcState> {
    return this.state;
  }
}

export class DiskStateStore {
  private state: MpcState;
  private storeFile: string;

  constructor(storePath: string) {
    this.storeFile = `${storePath}/state.json`;
    mkdirSync(storePath, { recursive: true });

    if (existsSync(this.storeFile)) {
      const buffer = readFileSync(this.storeFile);
      this.state = mpcStateFromJSON(JSON.parse(buffer.toString()));
    } else {
      this.state = defaultState();
    }
  }

  public async setState(state: MpcState) {
    this.state = state;
    // Atomic file update.
    await writeFileAsync(`${this.storeFile}.new`, JSON.stringify(this.state));
    await renameAsync(`${this.storeFile}.new`, this.storeFile);
  }

  public async getState(): Promise<MpcState> {
    return this.state;
  }
}