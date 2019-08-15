import { HttpClient } from 'setup-mpc-common';
import { Account } from 'web3x/account';
import { hexToBuffer } from 'web3x/utils';
import { App } from './app';

async function main() {
  const { API_URL = 'https://setup.aztecprotocol.com/api', PRIVATE_KEY = '', COMPUTE_OFFLINE = 0 } = process.env;
  const myAccount = PRIVATE_KEY ? Account.fromPrivate(hexToBuffer(PRIVATE_KEY)) : undefined;
  const server = new HttpClient(API_URL, myAccount);
  const app = new App(
    server,
    myAccount,
    process.stdout,
    process.stdout.rows!,
    process.stdout.columns!,
    +COMPUTE_OFFLINE > 0
  );

  app.start();

  process.stdout.on('resize', () => app.resize(process.stdout.columns!, process.stdout.rows!));
  process.once('SIGINT', () => app.stop());
  process.once('SIGTERM', () => app.stop());
}

main().catch(console.error);