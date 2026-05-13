# Smart Nyumba Admin Web Interface - Development Prompt

## Project Overview
Build a comprehensive web-based admin dashboard for Smart Nyumba property management system. The admin interface should provide complete system oversight, financial tracking, user management, and system configuration capabilities.

## Backend API Base URL
- **Production**: `https://api.smartnyumba.tech/apps/api/v1`

## Authentication

### Admin Login
**Endpoint**: `POST /auth/admin-login/`

**Request Body**:
```json
{
  "email": "admin@smartnyumba.tech",
  "password": "your_password"
}
```

**Response**:
```json
{
  "status": true,
  "message": "Login successful",
  "token": "auth_token_here",
  "user": {
    "id": 1,
    "email": "admin@smartnyumba.tech",
    "role": "admin"
  }
}
```

**Implementation Notes**:
- Store authentication token in localStorage/sessionStorage
- Include token in all subsequent requests as `Authorization: Token <token>`
- Redirect to login page if token expires (401 response)

### Admin Logout
**Endpoint**: `POST /auth/admin-logout/`

**Headers**: `Authorization: Token <token>`

**Response**:
```json
{
  "status": true,
  "message": "Logged out successfully"
}
```

### Admin Profile
**Endpoint**: `GET /auth/admin-profile/`

**Headers**: `Authorization: Token <token>`

**Response**:
```json
{
  "status": true,
  "profile": {
    "email": "admin@smartnyumba.tech",
    "name": "Admin Name",
    "role": "admin"
  }
}
```

## Core Features & Endpoints

### 1. Dashboard Overview
Create a main dashboard with key metrics and statistics.

#### Platform Earnings
**Endpoint**: `GET /admin/platform-earnings/`

**Headers**: `Authorization: Token <token>`

**Response**:
```json
{
  "status": true,
  "service_charge_commission": 15000.00,
  "rent_commission": 25000.00,
  "total_commission": 40000.00,
  "service_transactions_count": 150,
  "rent_transactions_count": 80,
  "total_transactions_count": 230
}
```

**Dashboard Cards to Display**:
- Total Platform Earnings (with trend indicator)
- Service Charge Commissions
- Rent Commissions
- Total Transactions Count
- Service vs Rent transaction breakdown (pie chart)
- Monthly earnings trend (line chart)

### 2. Tenant Management

#### View All Tenants
**Endpoint**: `GET /block-landlord/view-all-tenats/`

**Headers**: `Authorization: Token <token>`

**Response**:
```json
{
  "status": true,
  "tenants": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "id_number": "12345678",
      "block": {
        "block_number": "A",
        "house_number": "101"
      },
      "is_active": 1,
      "created_on": "2024-01-15"
    }
  ]
}
```

**Features to Implement**:
- Searchable tenant list (by name, email, ID number)
- Filter by block/house
- Filter by active/inactive status
- Export to CSV/Excel
- Pagination for large datasets
- View tenant details (click to expand)

#### View All Tenant Payments
**Endpoint**: `GET /admin/all-tenant-payments/`

**Headers**: `Authorization: Token <token>`

**Response**:
```json
{
  "status": true,
  "transactions": [
    {
      "id": 1,
      "tenant_name": "John Doe",
      "amount": 5000.00,
      "service_type": "Service Charge",
      "payment_date": "2024-01-15T10:30:00Z",
      "status": 0,
      "mpesa_receipt": "QXY123456"
    }
  ]
}
```

**Features to Implement**:
- Transaction history table with sorting
- Filter by date range
- Filter by payment type (service charge vs rent)
- Filter by status (pending/completed/failed)
- Search by tenant name or receipt number
- Export transactions to CSV/Excel
- View transaction details modal

### 3. System Configuration Management

#### Get System Configuration
**Endpoint**: `GET /admin/system-config/`

**Headers**: `Authorization: Token <token>`

**Response**:
```json
{
  "status": true,
  "landlord_activation_fee": 500.00,
  "platform_commission_rate": 0.05,
  "last_updated": "2024-01-15T10:30:00Z",
  "updated_by": "admin@smartnyumba.tech"
}
```

#### Update System Configuration
**Endpoint**: `POST /admin/update-system-config/`

**Headers**: `Authorization: Token <token>`

**Request Body**:
```json
{
  "landlord_activation_fee": 750.00,
  "platform_commission_rate": 0.06
}
```

**Response**:
```json
{
  "status": true,
  "message": "System configuration updated: Activation fee: KES 750.00, Commission rate: 6.0%",
  "landlord_activation_fee": 750.00,
  "platform_commission_rate": 0.06,
  "updated_by": "admin@smartnyumba.tech"
}
```

**Features to Implement**:
- Configuration settings page with form
- Input validation (activation fee >= 0, commission rate between 0-1)
- Display commission rate as percentage (multiply by 100)
- Confirmation dialog before saving changes
- Show last updated timestamp and admin who made the change
- Audit log of configuration changes
- Warning message if changing fees that affect pending payments

### 4. Financial Dashboard

#### Landlord Financial Summary (for monitoring)
**Endpoint**: `GET /block-landlord/financial-summary/`

**Headers**: `Authorization: Token <token>`

**Features to Implement**:
- Overview of all landlords' financial performance
- Revenue breakdown by property/block
- Outstanding payments tracking
- Commission earnings per landlord

## Technical Requirements

### Frontend Technology Stack
**Recommended**:
- **Framework**: React.js with TypeScript or Vue.js 3
- **State Management**: Redux Toolkit (React) or Pinia (Vue)
- **UI Library**: Material-UI, Ant Design, or Tailwind CSS + Headless UI
- **Charts**: Chart.js, Recharts, or ApexCharts
- **Data Tables**: TanStack Table (React Table v8) or AG Grid
- **HTTP Client**: Axios with interceptors for auth
- **Form Validation**: React Hook Form + Zod or VeeValidate + Yup
- **Date Handling**: date-fns or Day.js
- **Routing**: React Router v6 or Vue Router

### Architecture & Best Practices

#### 1. Authentication Flow
```typescript
// API client with interceptor
import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'https://api.smartnyumba.tech/apps/api/v1',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('admin_token');
    if (token) {
      config.headers.Authorization = `Token ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid
      localStorage.removeItem('admin_token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default apiClient;
```

#### 2. Protected Routes
```typescript
// ProtectedRoute component
import { Navigate } from 'react-router-dom';

const ProtectedRoute = ({ children }) => {
  const token = localStorage.getItem('admin_token');

  if (!token) {
    return <Navigate to="/login" replace />;
  }

  return children;
};
```

#### 3. API Service Layer
```typescript
// services/adminService.ts
import apiClient from './apiClient';

export const adminService = {
  // Auth
  login: (email: string, password: string) =>
    apiClient.post('/auth/admin-login/', { email, password }),

  logout: () =>
    apiClient.post('/auth/admin-logout/'),

  getProfile: () =>
    apiClient.get('/auth/admin-profile/'),

  // Platform Data
  getPlatformEarnings: () =>
    apiClient.get('/admin/platform-earnings/'),

  getAllTenants: () =>
    apiClient.get('/block-landlord/view-all-tenats/'),

  getAllPayments: () =>
    apiClient.get('/admin/all-tenant-payments/'),

  // System Config
  getSystemConfig: () =>
    apiClient.get('/admin/system-config/'),

  updateSystemConfig: (config: {
    landlord_activation_fee?: number;
    platform_commission_rate?: number;
  }) =>
    apiClient.post('/admin/update-system-config/', config),
};
```

## Page Structure & Navigation

### Main Layout
```
├── Sidebar Navigation
│   ├── Dashboard (Home)
│   ├── Tenants
│   ├── Payments/Transactions
│   ├── Platform Earnings
│   ├── System Settings
│   └── Profile
├── Top Navigation Bar
│   ├── Search
│   ├── Notifications
│   └── Admin Profile Dropdown
│       ├── My Profile
│       └── Logout
└── Main Content Area
```

### Page Details

#### 1. Dashboard Page (`/dashboard`)
**Components**:
- Welcome header with admin name
- 4 metric cards (Total Earnings, Service Commission, Rent Commission, Total Transactions)
- Earnings trend chart (last 12 months)
- Recent transactions table (last 10)
- Quick actions buttons

#### 2. Tenants Page (`/tenants`)
**Components**:
- Search and filter toolbar
- Data table with columns:
  - Name
  - Email
  - ID Number
  - Block/House
  - Status (Active/Inactive badge)
  - Joined Date
  - Actions (View Details)
- Pagination controls
- Export button

#### 3. Payments Page (`/payments`)
**Components**:
- Filter toolbar (date range, payment type, status)
- Transactions table with columns:
  - Date/Time
  - Tenant Name
  - Amount
  - Type (Service/Rent)
  - M-Pesa Receipt
  - Status (badge)
  - Platform Earnings
- Summary cards (total collected, platform share)
- Export functionality

#### 4. Platform Earnings Page (`/earnings`)
**Components**:
- Total earnings overview
- Commission breakdown (service vs rent)
- Transaction count statistics
- Earnings by month/quarter chart
- Top performing properties/blocks

#### 5. System Settings Page (`/settings`)
**Components**:
- Configuration form with sections:

  **Landlord Activation Fee**:
  - Input field (number, KES)
  - Current value display
  - Last updated info

  **Platform Commission Rate**:
  - Input field (percentage)
  - Slider for visual adjustment
  - Current value display
  - Impact calculator (show what X% commission means on sample amounts)

- Save button (with confirmation modal)
- Change history/audit log table

## UI/UX Guidelines

### Design Principles
1. **Clean & Professional**: Business-oriented, data-focused design
2. **Responsive**: Mobile-friendly (tablet minimum for admin tasks)
3. **Accessible**: WCAG 2.1 AA compliance
4. **Fast**: Optimized loading, skeleton screens, lazy loading
5. **Intuitive**: Clear navigation, consistent patterns

### Color Scheme
- **Primary**: #22215B (themePurple from app)
- **Accent**: #bc9f6d (buttonColor from app)
- **Success**: #4cd964 (paymentColor)
- **Warning**: #f68070 (serviceColor)
- **Error**: #dc3545
- **Neutral**: Grays for backgrounds and text

### Data Visualization
- Use consistent chart colors
- Include legends and labels
- Make charts interactive (hover tooltips)
- Provide data export options

## Security Considerations

1. **Authentication**:
   - Secure token storage
   - Auto-logout on inactivity (30 minutes)
   - Token refresh mechanism (if implemented in backend)

2. **Input Validation**:
   - Client-side validation for immediate feedback
   - Sanitize all inputs
   - Validate number ranges (fees, percentages)

3. **Data Protection**:
   - HTTPS only
   - No sensitive data in URLs
   - Clear sensitive data on logout

4. **Error Handling**:
   - User-friendly error messages
   - Log errors for debugging (without exposing sensitive info)
   - Graceful degradation

## Advanced Features (Optional Enhancements)

### 1. Real-time Updates
- WebSocket connection for live transaction updates
- Notification system for new payments
- Auto-refresh dashboard data

### 2. Advanced Analytics
- Revenue forecasting
- Tenant retention metrics
- Payment success rate trends
- Landlord performance rankings

### 3. Report Generation
- Monthly financial reports (PDF export)
- Custom date range reports
- Automated email reports

### 4. Bulk Operations
- Bulk tenant status updates
- Bulk configuration changes
- Mass notifications

### 5. Audit Trail
- Track all admin actions
- Configuration change history
- Login/logout logs
- Data modification logs

## Testing Requirements

### Unit Tests
- Component rendering
- Form validation logic
- API service functions
- Utility functions

### Integration Tests
- Authentication flow
- Data fetching and display
- Form submission workflows
- Navigation flows

### E2E Tests
- Complete user journeys
- Login → Dashboard → Perform action → Logout
- Configuration update flow
- Payment viewing and filtering

## Deployment

### Environment Variables
```env
VITE_API_BASE_URL=https://api.smartnyumba.tech/apps/api/v1
VITE_APP_NAME=Smart Nyumba Admin
VITE_SESSION_TIMEOUT=1800000
```

### Build & Deploy
1. Production build optimization
2. Asset compression (images, bundles)
3. CDN for static assets
4. Server-side rendering (optional, for SEO)
5. Monitoring and analytics (Google Analytics, Sentry)

## Development Workflow

### Phase 1: Setup & Authentication (Week 1)
- Project setup with chosen tech stack
- API client configuration
- Login/logout functionality
- Protected routing
- Basic layout structure

### Phase 2: Core Features (Week 2-3)
- Dashboard with metrics
- Tenants page
- Payments page
- Platform earnings page

### Phase 3: System Configuration (Week 4)
- Settings page
- Configuration update functionality
- Validation and error handling

### Phase 4: Polish & Testing (Week 5)
- UI/UX refinements
- Comprehensive testing
- Performance optimization
- Documentation

### Phase 5: Deployment (Week 6)
- Production build
- Deployment setup
- Monitoring configuration
- Training documentation

## API Endpoint Summary

| Feature | Method | Endpoint | Auth Required |
|---------|--------|----------|---------------|
| Admin Login | POST | `/auth/admin-login/` | No |
| Admin Logout | POST | `/auth/admin-logout/` | Yes |
| Admin Profile | GET | `/auth/admin-profile/` | Yes |
| Platform Earnings | GET | `/admin/platform-earnings/` | Yes |
| All Tenants | GET | `/block-landlord/view-all-tenats/` | Yes |
| All Payments | GET | `/admin/all-tenant-payments/` | Yes |
| Get System Config | GET | `/admin/system-config/` | Yes |
| Update System Config | POST | `/admin/update-system-config/` | Yes |

## Support & Documentation

### Developer Documentation
- API integration guide
- Component library documentation
- State management patterns
- Deployment guide

### User Documentation
- Admin user manual
- Feature walkthroughs
- Troubleshooting guide
- FAQ

---

## Quick Start Command

```bash
# Using React + Vite + TypeScript
npm create vite@latest smartnyumba-admin -- --template react-ts
cd smartnyumba-admin
npm install axios @tanstack/react-query react-router-dom
npm install -D @types/node

# Using Vue 3 + Vite + TypeScript
npm create vue@latest smartnyumba-admin
cd smartnyumba-admin
npm install axios pinia vue-router
npm install -D @types/node
```

## Success Metrics

Track these KPIs after deployment:
- Admin login success rate
- Average page load time
- Configuration update frequency
- Data export usage
- User error rate
- System uptime

---

**Note**: This is a comprehensive guide. Adjust the scope based on timeline and budget constraints. Prioritize core features (authentication, dashboard, configuration) before advanced features.
