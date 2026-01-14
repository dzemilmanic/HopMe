import dotenv from "dotenv";
dotenv.config();

import { BlobServiceClient } from '@azure/storage-blob';

const connectionString = process.env.AZURE_STORAGE_CONNECTION_STRING;
const containerName = process.env.AZURE_STORAGE_CONTAINER_NAME;

// Validacija da ne puca
if (!connectionString) {
  throw new Error("❌ AZURE_STORAGE_CONNECTION_STRING is not defined in the .env file");
}

if (!containerName) {
  throw new Error("❌ AZURE_STORAGE_CONNECTION_STRING is not defined in the .env file");
}

const blobServiceClient = BlobServiceClient.fromConnectionString(connectionString);
const containerClient = blobServiceClient.getContainerClient(containerName);

export { blobServiceClient, containerClient };
