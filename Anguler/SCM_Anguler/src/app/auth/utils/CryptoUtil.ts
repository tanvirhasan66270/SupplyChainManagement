
// npm install crypto-js
// npm install --save-dev @types/crypto-js

import CryptoJS from "crypto-js";
import { SECRET } from "../../../environment/environment";





// npm install --save-dev @types/crypto-js
export const CryptoUtil = {

  encrypt(value: string): string {
    return CryptoJS.AES.encrypt(value, SECRET).toString();
  },

  decrypt(cipher: string): string | null {
    try {
      const bytes = CryptoJS.AES.decrypt(cipher, SECRET);
      const result = bytes.toString(CryptoJS.enc.Utf8);
      return result || null;
    } catch {
      return null;
    }
  }

};
