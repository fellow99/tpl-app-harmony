import { image } from '@kit.ImageKit';
import { util } from '@kit.ArkTS';

/**
 * 验证码图片工具：将后端返回的 Base64 data URL 解码为 PixelMap 供 Image 组件渲染。
 */
export class CaptchaUtil {
  /**
   * 解码 Base64 图片 data URL 为 PixelMap。
   *
   * @param dataUrl 形如 data:image/png;base64,xxxx 的字符串。
   * @return 解码后的 PixelMap。
   */
  static async decode(dataUrl: string): Promise<image.PixelMap> {
    const commaIndex: number = dataUrl.indexOf(',');
    const base64: string = dataUrl.substring(commaIndex + 1);
    const helper: util.Base64Helper = new util.Base64Helper();
    const bytes: Uint8Array = helper.decodeSync(base64);
    const imageSource: image.ImageSource = image.createImageSource(bytes.buffer);
    return await imageSource.createPixelMap();
  }
}
