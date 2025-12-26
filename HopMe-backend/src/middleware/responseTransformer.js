/**
 * Middleware to transform all responses to camelCase and parse PostgreSQL arrays
 * This ensures iOS compatibility without modifying each controller
 */

// Convert snake_case to camelCase
const toCamelCase = (str) => {
  return str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
};

// Parse PostgreSQL array string to proper array
const parsePostgresArray = (value) => {
  if (Array.isArray(value)) return value;
  if (typeof value === 'string' && value.startsWith('{') && value.endsWith('}')) {
    return value.replace(/[{}]/g, '').split(',').filter(r => r.trim());
  }
  return value;
};

// Recursively transform object keys to camelCase and parse arrays
const transformResponse = (obj) => {
  if (obj === null || obj === undefined) return obj;
  if (Array.isArray(obj)) return obj.map(transformResponse);
  if (typeof obj !== 'object') return obj;
  if (obj instanceof Date) return obj;
  
  const transformed = {};
  for (const [key, value] of Object.entries(obj)) {
    const camelKey = toCamelCase(key);
    
    // Special handling for roles field
    if (key === 'roles') {
      transformed[camelKey] = parsePostgresArray(value);
    } else if (typeof value === 'object' && value !== null && !(value instanceof Date)) {
      transformed[camelKey] = transformResponse(value);
    } else {
      transformed[camelKey] = value;
    }
  }
  return transformed;
};

// Middleware function
const responseTransformer = (req, res, next) => {
  const originalJson = res.json.bind(res);
  
  res.json = (data) => {
    const transformed = transformResponse(data);
    return originalJson(transformed);
  };
  
  next();
};

export default responseTransformer;
