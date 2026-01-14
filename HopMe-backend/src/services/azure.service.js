import { containerClient } from '../config/azure.js';
import { v4 as uuidv4 } from 'uuid';

class AzureService {
  static async uploadImage(file) {
    try {
      const blobName = `${uuidv4()}-${Date.now()}-${file.originalname}`;
      const blockBlobClient = containerClient.getBlockBlobClient(blobName);
      
      await blockBlobClient.uploadData(file.buffer, {
        blobHTTPHeaders: { blobContentType: file.mimetype }
      });
      
      return {
        url: blockBlobClient.url,
        blobName: blobName
      };
    } catch (error) {
      console.error('Azure upload error:', error);
      throw new Error('Error uploading image');
    }
  }

  static async deleteImage(blobName) {
    try {
      const blockBlobClient = containerClient.getBlockBlobClient(blobName);
      await blockBlobClient.delete();
      return true;
    } catch (error) {
      console.error('Azure delete error:', error);
      return false;
    }
  }

  static async deleteMultipleImages(blobNames) {
    const promises = blobNames.map(name => this.deleteImage(name));
    return await Promise.all(promises);
  }
}

export default AzureService;