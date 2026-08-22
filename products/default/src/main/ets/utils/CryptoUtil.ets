import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { util } from '@kit.ArkTS';

/**
 * AES+RSA 混合加密工具（cryptoFramework），与后端 tpl-app-api ApiDecryptFilter wire 契约一致：
 * - AES-256-ECB-PKCS7 加密请求体 JSON，密钥为 32 字符随机 hex 字符串的 UTF-8 字节（32 字节）
 * - RSA-2048 PKCS#1 v1.5 公钥加密 Base64(AES key)
 */
export class CryptoUtil {
  /** 服务端 RSA 公钥（X.509 PEM），与 tpl-app-api RSA_PRIVATE_KEY 配对 */
  private static readonly RSA_PUBLIC_KEY_PEM: string =
    '-----BEGIN PUBLIC KEY-----\n' +
    'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn/ZuIrZ8gHDxlwJnHSnq\n' +
    '4PnLqfh9FsqtuysM/mJfTCH70srPiAXtp4g5GET/ArpHG8ne1zjmOZCtVDpTKhK4\n' +
    'DT3lRcOnKcjPwwW0hS+SGEAXawIFkwZ/Gb67Iw33H3Jlc5LHd0zZBzFU/PA9wDyo\n' +
    'b4pkV8EUx7VycO/5uIwSnxCnSFeg4OQAhJQstMGAXMYFRF1Ste95pACilRHROXOB\n' +
    'dh2xSbJQgHFRlrG7LrkXKXhrOQnF8EQB8GFeLXhANddoRDJ+z9/9JQ7KAAGdfb/s\n' +
    'xaxpNBHQFtXy6Vq/ydQ5EdUWEzrWlzAjfjXgygZiJcs6NFyif5X9oUBH9DA+Y15x\n' +
    'wwIDAQAB\n' +
    '-----END PUBLIC KEY-----';

  private static readonly base64: util.Base64Helper = new util.Base64Helper();

  /** 生成 32 字符随机 hex 字符串（16 字节随机数） */
  static generateAesKeyHex(): string {
    const rand = cryptoFramework.createRandom();
    const bytes: cryptoFramework.DataBlob = rand.generateRandomSync(16);
    let hex = '';
    for (let i = 0; i < bytes.data.length; i++) {
      hex += bytes.data[i].toString(16).padStart(2, '0');
    }
    return hex;
  }

  /** AES-256-ECB-PKCS7 加密，返回 Base64(AES(plaintext)) */
  static async aesEncrypt(plaintext: string, aesKeyHex: string): Promise<string> {
    const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES256');
    const keyBytes: cryptoFramework.DataBlob = { data: CryptoUtil.strToBytes(aesKeyHex) };
    const symKey = await symKeyGenerator.convertKey(keyBytes);
    const cipher = cryptoFramework.createCipher('AES256|ECB|PKCS7');
    await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, null);
    const plainBytes: cryptoFramework.DataBlob = { data: CryptoUtil.strToBytes(plaintext) };
    const encrypted: cryptoFramework.DataBlob = await cipher.doFinal(plainBytes);
    return CryptoUtil.base64.encodeToStringSync(encrypted.data);
  }

  /** RSA-2048 PKCS#1 v1.5 公钥加密，返回 Base64 密文 */
  static async rsaEncrypt(plaintext: string): Promise<string> {
    const asyKeyGenerator = cryptoFramework.createAsyKeyGenerator('RSA2048');
    const pubKeyBlob: cryptoFramework.DataBlob = { data: CryptoUtil.pemToDer(CryptoUtil.RSA_PUBLIC_KEY_PEM) };
    const keyPair = await asyKeyGenerator.convertKey(pubKeyBlob, null);
    const cipher = cryptoFramework.createCipher('RSA2048|PKCS1');
    await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, keyPair.pubKey, null);
    const plainBytes: cryptoFramework.DataBlob = { data: CryptoUtil.strToBytes(plaintext) };
    const encrypted: cryptoFramework.DataBlob = await cipher.doFinal(plainBytes);
    return CryptoUtil.base64.encodeToStringSync(encrypted.data);
  }

  /** 对 hex 字符串的 UTF-8 字节做 Base64 编码（供 RSA 公钥加密） */
  static base64Encode(hexStr: string): string {
    return CryptoUtil.base64.encodeToStringSync(CryptoUtil.strToBytes(hexStr));
  }

  private static strToBytes(str: string): Uint8Array {
    const bytes = new Uint8Array(str.length);
    for (let i = 0; i < str.length; i++) {
      bytes[i] = str.charCodeAt(i) & 0xff;
    }
    return bytes;
  }

  private static pemToDer(pem: string): Uint8Array {
    const b64 = pem
      .replace('-----BEGIN PUBLIC KEY-----', '')
      .replace('-----END PUBLIC KEY-----', '')
      .replace(/\s/g, '');
    return CryptoUtil.base64.decodeSync(b64);
  }
}
