import { supabase } from './supabase';

// Mock Stripe types
interface MockStripeSession {
  id: string;
  success_url: string;
  cancel_url: string;
}

interface MockStripeSubscription {
  id: string;
  status: 'active' | 'canceled' | 'past_due';
  current_period_end: string;
}

// Mock Stripe functionality
export const mockStripe = {
  // Create a checkout session
  createCheckoutSession: async (commodityId: string): Promise<MockStripeSession> => {
    // Get user
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Create mock session
    return {
      id: `mock_session_${Math.random().toString(36).slice(2)}`,
      success_url: `/dashboard/commodities/${commodityId}`,
      cancel_url: '/dashboard/store'
    };
  },

  // Get subscription status
  getSubscription: async (): Promise<MockStripeSubscription> => {
    // Get user
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 500));

    // Return mock subscription
    return {
      id: `mock_sub_${Math.random().toString(36).slice(2)}`,
      status: 'active',
      current_period_end: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
    };
  },

  // Cancel subscription
  cancelSubscription: async (commodityId: string): Promise<void> => {
    // Get user
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 800));

    // Update portfolio status in Supabase
    const { error } = await supabase
      .from('commodity_portfolio')
      .update({ status: 'inactive' })
      .eq('user_id', user.id)
      .eq('commodity_id', commodityId);

    if (error) throw error;
  }
};