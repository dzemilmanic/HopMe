import mongoose from 'mongoose';

const testimonialSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true  // One testimonial per user
  },
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },
  text: {
    type: String,
    required: true,
    trim: true,
    maxlength: 500
  },
  isApproved: {
    type: Boolean,
    default: true  // Auto-approved for now
  }
}, {
  timestamps: true
});

// Index for faster queries
testimonialSchema.index({ createdAt: -1 });
testimonialSchema.index({ isApproved: 1 });

export default mongoose.model('Testimonial', testimonialSchema);
