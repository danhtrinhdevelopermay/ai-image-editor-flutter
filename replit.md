# AI Image Editor

## Overview

This project includes both a web application and a Flutter mobile app that provide AI-powered image editing capabilities, specifically background removal and object removal from images. The web version uses React frontend with Express backend, while the Flutter app is built for Android APK distribution. Both integrate with the Clipdrop API for AI image processing.

## User Preferences

Preferred communication style: Simple, everyday language.

## Recent Changes (July 27, 2025)

✓ Created complete Flutter application for Android APK build
✓ Added all required dependencies and permissions
✓ Implemented full UI with Vietnamese language support
✓ Configured Clipdrop API integration
✓ Added comprehensive documentation and build instructions
✓ Set up GitHub Actions workflow for automated APK building
✓ Successfully migrated from Replit Agent to Replit environment
✓ Updated application to only support background removal (Clipdrop API limitation)
✓ Fixed all TypeScript issues and security configurations
✓ Verified application is working properly in Replit
✓ Created professional animated splash screen with transparent system bars
✓ Integrated custom app_icon.png logo throughout entire Flutter app
✓ Generated all Android icon sizes automatically using ImageMagick
✓ Updated app branding from "AI Image Editor" to "Photo Magic"
✓ Enhanced Flutter app with comprehensive Clipdrop API integration (v2.0.0)
✓ Added all 7 new Clipdrop API features with intuitive categorized UI
✓ Created EnhancedEditorWidget with PageView navigation and smart input dialogs
✓ Implemented TextToImageWidget for generating images from text descriptions
✓ Added comprehensive Vietnamese documentation and updated README
✓ Implemented automatic API failover system with backup Clipdrop API key
✓ Updated GitHub Actions workflow with personal access token for automated APK builds
✓ Fixed GitHub Actions build failures by removing problematic analysis and test steps
✓ Added comprehensive API failover documentation and error handling improvements
✓ Fixed critical APK build issues in GitHub Actions workflow (January 27, 2025)
✓ Updated Android Gradle configuration to modern versions (compileSdk 34, targetSdk 34)
✓ Created missing Gradle wrapper files and fixed permissions
✓ Enhanced CI/CD workflow with better error handling and diagnostics

## System Architecture

### Web Application
#### Frontend Architecture
- **Framework**: React 18 with TypeScript
- **Routing**: Wouter for client-side routing
- **State Management**: TanStack Query (React Query) for server state management
- **UI Framework**: Tailwind CSS with shadcn/ui component library
- **Build Tool**: Vite for development and production builds
- **Component Design**: Radix UI primitives for accessible, unstyled components

#### Backend Architecture
- **Runtime**: Node.js with Express.js framework
- **Language**: TypeScript with ES modules
- **API Pattern**: RESTful API design
- **File Handling**: Multer for multipart/form-data file uploads
- **External API**: Clipdrop API integration for AI image processing

#### Database Architecture
- **ORM**: Drizzle ORM for type-safe database operations
- **Database**: PostgreSQL (configured for Neon serverless)
- **Migrations**: Drizzle Kit for schema migrations
- **Schema**: Centralized schema definition in shared directory

### Flutter Mobile Application
#### Mobile Architecture
- **Framework**: Flutter 3.22.0 with Dart
- **State Management**: Provider pattern for reactive state management
- **UI Design**: Material 3 with custom gradient themes
- **Routing**: Single-screen app with state-based navigation
- **Platform**: Android APK build ready with GitHub Actions support

#### Mobile Dependencies
- **Image Handling**: image_picker, image packages for file operations
- **HTTP Requests**: dio, http for Clipdrop API communication
- **File Storage**: path_provider, share_plus for local storage and sharing
- **UI Enhancements**: flutter_spinkit, flutter_staggered_animations
- **Permissions**: permission_handler for Android permissions

#### Build Configuration
- **Android**: Configured with all necessary permissions (Camera, Storage, Internet)
- **APK Build**: Support for debug, release, and split-per-abi builds
- **CI/CD**: GitHub Actions workflow for automated APK generation

## Key Components

### Data Storage
- **Current Implementation**: In-memory storage using Map data structure
- **Production Ready**: PostgreSQL schema defined for image jobs
- **Storage Strategy**: File uploads stored in local `uploads/` directory
- **Job Tracking**: Comprehensive job status tracking (pending, processing, completed, failed)

### Image Processing Pipeline
1. **Upload Validation**: File type (JPEG, PNG, WEBP) and size (10MB) restrictions
2. **Job Creation**: Database record creation with metadata
3. **AI Processing**: Clipdrop API integration for background/object removal
4. **Result Storage**: Processed images saved and linked to jobs
5. **Status Updates**: Real-time job status updates

### UI Components
- **Upload Area**: Drag-and-drop file upload interface
- **Image Editor**: Preview and operation selection
- **Processing Overlay**: Real-time progress indication
- **Results View**: Before/after comparison with download/share options
- **Bottom Navigation**: Mobile-first navigation pattern

## Data Flow

1. **File Upload**: User selects image file → Frontend validation → FormData creation
2. **Job Creation**: POST /api/jobs → Multer file processing → Database job record
3. **AI Processing**: POST /api/jobs/:id/process → Clipdrop API call → Result storage
4. **Status Polling**: Frontend queries job status → Real-time UI updates
5. **Result Display**: Processed image URL → Download/share functionality

## External Dependencies

### Core Dependencies
- **@neondatabase/serverless**: PostgreSQL serverless connection
- **@tanstack/react-query**: Server state management
- **drizzle-orm**: Type-safe ORM
- **multer**: File upload handling
- **date-fns**: Date manipulation utilities

### UI Dependencies
- **@radix-ui/***: Accessible UI primitives
- **tailwindcss**: Utility-first CSS framework
- **class-variance-authority**: Component variant management
- **cmdk**: Command palette component

### External Services
- **Clipdrop API**: AI image processing service
  - Background removal endpoint
  - Object cleanup endpoint
  - Requires API key authentication

## Deployment Strategy

### Development Environment
- **Dev Server**: Vite development server with HMR
- **API Server**: tsx for TypeScript execution
- **Database**: Local PostgreSQL or Neon development database

### Production Build
- **Frontend**: Vite static build to `dist/public`
- **Backend**: esbuild bundling to `dist/index.js`
- **Database**: Drizzle migrations for schema deployment
- **Environment**: NODE_ENV=production with optimized settings

### Configuration Requirements
- **DATABASE_URL**: PostgreSQL connection string
- **CLIPDROP_API_KEY**: Clipdrop service authentication
- **File Storage**: Persistent storage solution for uploaded/processed images

### Scalability Considerations
- **File Storage**: Current local storage needs cloud storage (S3, Cloudinary)
- **Database**: PostgreSQL ready for production scaling
- **API Rate Limits**: Clipdrop API usage monitoring needed
- **Caching**: React Query provides client-side caching
- **Error Handling**: Comprehensive error boundaries and API error handling

The architecture supports both development and production environments with clear separation of concerns, type safety throughout the stack, and modern web development best practices.